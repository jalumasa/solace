package com.jonathanalumasa.solace.service.firebase

import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import com.jonathanalumasa.solace.model.GratitudeEntry
import com.jonathanalumasa.solace.model.MoodEntry
import com.jonathanalumasa.solace.model.MoodLevel
import com.jonathanalumasa.solace.service.JournalService
import com.jonathanalumasa.solace.service.MoodService
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.tasks.await
import java.util.Date

/**
 * Firebase-backed [MoodService]. Mood entries live in an owner-only
 * subcollection (`/users/{uid}/moodEntries`) — never shared with counselors.
 */
class FirestoreMoodService(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) : MoodService {

    override suspend fun logMood(mood: MoodLevel, note: String?, userID: String) {
        val data = mutableMapOf<String, Any>(
            "mood" to mood.rawValue,
            "createdAt" to FieldValue.serverTimestamp()
        )
        note?.let { data["note"] = it }

        firestore.collection("users").document(userID)
            .collection("moodEntries")
            .add(data)
            .await()
    }

    override fun observeMoodHistory(userID: String): Flow<List<MoodEntry>> =
        firestore.collection("users").document(userID)
            .collection("moodEntries")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .snapshotListFlow(::entry)

    private fun entry(document: DocumentSnapshot): MoodEntry? {
        val mood = MoodLevel.fromRaw(document.getLong("mood")?.toInt()) ?: return null
        return MoodEntry(
            id = document.id,
            mood = mood,
            note = document.getString("note"),
            createdAt = document.getDate("createdAt") ?: Date()
        )
    }
}

/**
 * Firebase-backed [JournalService] for the Gratitude Garden, using the same
 * owner-only subcollection pattern as mood entries.
 */
class FirestoreJournalService(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) : JournalService {

    override suspend fun addGratitudeEntry(text: String, userID: String) {
        firestore.collection("users").document(userID)
            .collection("gratitudeEntries")
            .add(
                mapOf(
                    "text" to text,
                    "createdAt" to FieldValue.serverTimestamp()
                )
            )
            .await()
    }

    override fun observeGratitudeEntries(userID: String): Flow<List<GratitudeEntry>> =
        firestore.collection("users").document(userID)
            .collection("gratitudeEntries")
            .orderBy("createdAt", Query.Direction.DESCENDING)
            .snapshotListFlow(::entry)

    private fun entry(document: DocumentSnapshot): GratitudeEntry? {
        val text = document.getString("text") ?: return null
        return GratitudeEntry(
            id = document.id,
            text = text,
            createdAt = document.getDate("createdAt") ?: Date()
        )
    }
}
