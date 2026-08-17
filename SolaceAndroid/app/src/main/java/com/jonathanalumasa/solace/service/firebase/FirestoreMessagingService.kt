package com.jonathanalumasa.solace.service.firebase

import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.SetOptions
import com.jonathanalumasa.solace.model.AcademicYear
import com.jonathanalumasa.solace.model.Conversation
import com.jonathanalumasa.solace.model.Message
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.service.MessagingService
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.tasks.await
import java.util.Date

/**
 * Firebase-backed implementation of [MessagingService]. Conversation documents
 * store both participant IDs (for querying) and their display names
 * (denormalized at creation time), so the conversation list doesn't need a
 * lookup per row.
 */
class FirestoreMessagingService(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) : MessagingService {

    override suspend fun fetchCounselors(): List<User> =
        firestore.collection("users")
            .whereEqualTo("role", Role.COUNSELOR.rawValue)
            .get()
            .await()
            .documents
            .mapNotNull(::user)

    override suspend fun startConversation(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String
    ): Conversation {
        // Filtered by participantIDs (not studentID/counselorID) so the query
        // shape matches what the security rule can prove safe — a compound
        // equality filter on studentID/counselorID can't be verified against
        // an `auth.uid in participantIDs` rule and gets rejected outright.
        val existing = firestore.collection("conversations")
            .whereArrayContains("participantIDs", studentID)
            .get()
            .await()
            .documents
            .firstOrNull { it.getString("counselorID") == counselorID }

        existing?.let { document ->
            conversation(document)?.let { return it }
        }

        val reference = firestore.collection("conversations").document()
        reference.set(
            mapOf(
                "studentID" to studentID,
                "studentName" to studentName,
                "counselorID" to counselorID,
                "counselorName" to counselorName,
                "participantIDs" to listOf(studentID, counselorID),
                "createdAt" to FieldValue.serverTimestamp()
            )
        ).await()

        return Conversation(
            id = reference.id,
            studentID = studentID,
            studentName = studentName,
            counselorID = counselorID,
            counselorName = counselorName
        )
    }

    override fun observeConversations(userID: String): Flow<List<Conversation>> =
        firestore.collection("conversations")
            .whereArrayContains("participantIDs", userID)
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .snapshotListFlow(::conversation)

    override fun observeMessages(conversationID: String): Flow<List<Message>> =
        firestore.collection("conversations").document(conversationID)
            .collection("messages")
            .orderBy("sentAt")
            .snapshotListFlow { message(it, conversationID) }

    override suspend fun sendMessage(conversationID: String, senderID: String, text: String) {
        val conversationRef = firestore.collection("conversations").document(conversationID)
        conversationRef.collection("messages").add(
            mapOf(
                "senderID" to senderID,
                "text" to text,
                "sentAt" to FieldValue.serverTimestamp()
            )
        ).await()
        conversationRef.set(
            mapOf(
                "lastMessageText" to text,
                "lastMessageAt" to FieldValue.serverTimestamp()
            ),
            SetOptions.merge()
        ).await()
    }

    private fun user(document: DocumentSnapshot): User? {
        val role = Role.fromRaw(document.getString("role")) ?: return null
        return User(
            id = document.id,
            email = document.getString("email") ?: "",
            displayName = document.getString("displayName") ?: "",
            role = role,
            bio = document.getString("bio"),
            major = document.getString("major"),
            academicYear = AcademicYear.fromRaw(document.getString("academicYear")),
            age = document.getLong("age")?.toInt()
        )
    }

    private fun conversation(document: DocumentSnapshot): Conversation? {
        val studentID = document.getString("studentID") ?: return null
        val counselorID = document.getString("counselorID") ?: return null
        return Conversation(
            id = document.id,
            studentID = studentID,
            studentName = document.getString("studentName") ?: "Student",
            counselorID = counselorID,
            counselorName = document.getString("counselorName") ?: "Counselor",
            lastMessageText = document.getString("lastMessageText"),
            lastMessageAt = document.getDate("lastMessageAt"),
            createdAt = document.getDate("createdAt") ?: Date()
        )
    }

    private fun message(document: DocumentSnapshot, conversationID: String): Message? {
        val senderID = document.getString("senderID") ?: return null
        val text = document.getString("text") ?: return null
        return Message(
            id = document.id,
            conversationID = conversationID,
            senderID = senderID,
            text = text,
            sentAt = document.getDate("sentAt") ?: Date()
        )
    }
}
