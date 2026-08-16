package com.jonathanalumasa.solace.model

import java.util.Date

/**
 * Mirrors `SolaceCore.SupportCircle`. Circles are curated/seeded, not
 * user-created — firestore.rules blocks client-side create/delete.
 */
data class SupportCircle(
    val id: String,
    val name: String,
    val topicDescription: String,
    val memberIDs: List<String> = emptyList(),
    val createdAt: Date = Date()
) {
    fun isMember(userID: String): Boolean = memberIDs.contains(userID)
}

/** Mirrors `SolaceCore.CircleMessage`. */
data class CircleMessage(
    val id: String,
    val circleID: String,
    val senderID: String,
    val senderName: String,
    val text: String,
    val sentAt: Date = Date()
)
