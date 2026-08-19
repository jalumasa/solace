package com.jonathanalumasa.solace.model

import java.util.Date

/** Mirrors `SolaceCore.AppointmentStatus`. */
enum class AppointmentStatus(val rawValue: String, val label: String) {
    PENDING("pending", "Pending"),
    CONFIRMED("confirmed", "Confirmed"),
    DECLINED("declined", "Declined"),
    CANCELLED("cancelled", "Cancelled");

    companion object {
        fun fromRaw(raw: String?): AppointmentStatus? = entries.firstOrNull { it.rawValue == raw }
    }
}

/** Mirrors `SolaceCore.Appointment`. */
data class Appointment(
    val id: String,
    val studentID: String,
    val studentName: String,
    val counselorID: String,
    val counselorName: String,
    val scheduledAt: Date,
    val status: AppointmentStatus = AppointmentStatus.PENDING,
    val createdAt: Date = Date()
) {
    val participantIDs: List<String> get() = listOf(studentID, counselorID)

    fun otherParticipantName(currentUserID: String): String =
        if (currentUserID == studentID) counselorName else studentName
}
