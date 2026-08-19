package com.jonathanalumasa.solace.service

import com.jonathanalumasa.solace.model.AIChatMessage
import com.jonathanalumasa.solace.model.Appointment
import com.jonathanalumasa.solace.model.AppointmentStatus
import com.jonathanalumasa.solace.model.CircleMessage
import com.jonathanalumasa.solace.model.Conversation
import com.jonathanalumasa.solace.model.GratitudeEntry
import com.jonathanalumasa.solace.model.Message
import com.jonathanalumasa.solace.model.MoodEntry
import com.jonathanalumasa.solace.model.MoodLevel
import com.jonathanalumasa.solace.model.ResourceItem
import com.jonathanalumasa.solace.model.SupportCircle
import com.jonathanalumasa.solace.model.User
import kotlinx.coroutines.flow.Flow
import java.util.Date

/** Mirrors `SolaceCore.MessagingServicing`. */
interface MessagingService {
    suspend fun fetchCounselors(): List<User>
    suspend fun startConversation(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String
    ): Conversation

    fun observeConversations(userID: String): Flow<List<Conversation>>
    fun observeMessages(conversationID: String): Flow<List<Message>>
    suspend fun sendMessage(conversationID: String, senderID: String, text: String)
}

/** Mirrors `SolaceCore.MoodServicing`. */
interface MoodService {
    suspend fun logMood(mood: MoodLevel, note: String?, userID: String)
    fun observeMoodHistory(userID: String): Flow<List<MoodEntry>>
}

/** Mirrors `SolaceCore.JournalServicing`. */
interface JournalService {
    suspend fun addGratitudeEntry(text: String, userID: String)
    fun observeGratitudeEntries(userID: String): Flow<List<GratitudeEntry>>
}

/** Mirrors `SolaceCore.AppointmentServicing`. */
interface AppointmentService {
    suspend fun requestAppointment(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String,
        scheduledAt: Date
    ): Appointment

    fun observeAppointments(userID: String): Flow<List<Appointment>>
    suspend fun updateStatus(appointmentID: String, status: AppointmentStatus)
}

/** Mirrors `SolaceCore.CircleServicing`. */
interface CircleService {
    fun observeCircles(): Flow<List<SupportCircle>>
    suspend fun join(circleID: String, userID: String)
    suspend fun leave(circleID: String, userID: String)
    fun observeMessages(circleID: String): Flow<List<CircleMessage>>
    suspend fun sendMessage(circleID: String, senderID: String, senderName: String, text: String)
}

/** Mirrors `SolaceCore.AIChatServicing`. */
interface AIChatService {
    suspend fun sendMessage(history: List<AIChatMessage>, newMessage: String): String
}

/** Mirrors `SolaceCore.AIChatError`. */
sealed class AIChatError(message: String? = null) : Exception(message) {
    data object NotSignedIn : AIChatError()
    data object Network : AIChatError()
    data object RateLimited : AIChatError()
    data class Unknown(val detail: String) : AIChatError(detail)
}

/** Mirrors `SolaceCore.ResourceServicing`. */
interface ResourceService {
    suspend fun fetchResources(): List<ResourceItem>
}
