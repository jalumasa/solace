package com.jonathanalumasa.solace.service.firebase

import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.SetOptions
import com.jonathanalumasa.solace.model.CircleMessage
import com.jonathanalumasa.solace.model.SupportCircle
import com.jonathanalumasa.solace.service.CircleService
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.tasks.await
import java.util.Date

/**
 * Firebase-backed [CircleService]. Circles themselves are seeded server-side
 * (firestore.rules disallows client create/delete); this service only supports
 * browsing, joining/leaving, and posting within a circle.
 */
class FirestoreCircleService(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) : CircleService {

    override fun observeCircles(): Flow<List<SupportCircle>> =
        firestore.collection("circles")
            .orderBy("name")
            .snapshotListFlow(::circle)

    override suspend fun join(circleID: String, userID: String) {
        firestore.collection("circles").document(circleID)
            .set(mapOf("memberIDs" to FieldValue.arrayUnion(userID)), SetOptions.merge())
            .await()
    }

    override suspend fun leave(circleID: String, userID: String) {
        firestore.collection("circles").document(circleID)
            .set(mapOf("memberIDs" to FieldValue.arrayRemove(userID)), SetOptions.merge())
            .await()
    }

    override fun observeMessages(circleID: String): Flow<List<CircleMessage>> =
        firestore.collection("circles").document(circleID)
            .collection("messages")
            .orderBy("sentAt")
            .snapshotListFlow { message(it, circleID) }

    override suspend fun sendMessage(
        circleID: String,
        senderID: String,
        senderName: String,
        text: String
    ) {
        firestore.collection("circles").document(circleID)
            .collection("messages")
            .add(
                mapOf(
                    "senderID" to senderID,
                    "senderName" to senderName,
                    "text" to text,
                    "sentAt" to FieldValue.serverTimestamp()
                )
            )
            .await()
    }

    private fun circle(document: DocumentSnapshot): SupportCircle? {
        val name = document.getString("name") ?: return null
        @Suppress("UNCHECKED_CAST")
        val memberIDs = document.get("memberIDs") as? List<String> ?: emptyList()
        return SupportCircle(
            id = document.id,
            name = name,
            topicDescription = document.getString("topicDescription") ?: "",
            memberIDs = memberIDs,
            createdAt = document.getDate("createdAt") ?: Date()
        )
    }

    private fun message(document: DocumentSnapshot, circleID: String): CircleMessage? {
        val senderID = document.getString("senderID") ?: return null
        val text = document.getString("text") ?: return null
        return CircleMessage(
            id = document.id,
            circleID = circleID,
            senderID = senderID,
            senderName = document.getString("senderName") ?: "Member",
            text = text,
            sentAt = document.getDate("sentAt") ?: Date()
        )
    }
}
