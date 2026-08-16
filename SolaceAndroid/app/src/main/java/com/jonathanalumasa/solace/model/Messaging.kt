package com.jonathanalumasa.solace.model

import java.util.Date

/** Mirrors `SolaceCore.Conversation`. */
data class Conversation(
    val id: String,
    val studentID: String,
    val studentName: String,
    val counselorID: String,
    val counselorName: String,
    val lastMessageText: String? = null,
    val lastMessageAt: Date? = null,
    val createdAt: Date = Date()
) {
    val participantIDs: List<String> get() = listOf(studentID, counselorID)

    fun otherParticipantName(currentUserID: String): String =
        if (currentUserID == studentID) counselorName else studentName
}

/** Mirrors `SolaceCore.Message`. */
data class Message(
    val id: String,
    val conversationID: String,
    val senderID: String,
    val text: String,
    val sentAt: Date = Date()
)

/** Mirrors `SolaceCore.AIChatRole`. */
enum class AIChatRole(val rawValue: String) {
    USER("user"),
    ASSISTANT("assistant")
}

/** Mirrors `SolaceCore.AIChatMessage`. Not persisted — session-local only. */
data class AIChatMessage(
    val id: String = java.util.UUID.randomUUID().toString(),
    val role: AIChatRole,
    val text: String,
    val sentAt: Date = Date()
)
