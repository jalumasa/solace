package com.jonathanalumasa.solace.service.firebase

import com.google.firebase.Timestamp
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.SetOptions
import com.jonathanalumasa.solace.model.Appointment
import com.jonathanalumasa.solace.model.AppointmentStatus
import com.jonathanalumasa.solace.service.AppointmentService
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.tasks.await
import java.util.Date

/**
 * Firebase-backed [AppointmentService]. Appointment documents store
 * participant IDs (for querying, same idiom as conversations) alongside
 * denormalized display names.
 */
class FirestoreAppointmentService(
    private val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
) : AppointmentService {

    override suspend fun requestAppointment(
        studentID: String,
        studentName: String,
        counselorID: String,
        counselorName: String,
        scheduledAt: Date
    ): Appointment {
        val reference = firestore.collection("appointments").document()
        reference.set(
            mapOf(
                "studentID" to studentID,
                "studentName" to studentName,
                "counselorID" to counselorID,
                "counselorName" to counselorName,
                "participantIDs" to listOf(studentID, counselorID),
                "scheduledAt" to Timestamp(scheduledAt),
                "status" to AppointmentStatus.PENDING.rawValue,
                "createdAt" to FieldValue.serverTimestamp()
            )
        ).await()

        return Appointment(
            id = reference.id,
            studentID = studentID,
            studentName = studentName,
            counselorID = counselorID,
            counselorName = counselorName,
            scheduledAt = scheduledAt
        )
    }

    override fun observeAppointments(userID: String): Flow<List<Appointment>> =
        firestore.collection("appointments")
            .whereArrayContains("participantIDs", userID)
            .orderBy("scheduledAt")
            .snapshotListFlow(::appointment)

    override suspend fun updateStatus(appointmentID: String, status: AppointmentStatus) {
        firestore.collection("appointments").document(appointmentID)
            .set(mapOf("status" to status.rawValue), SetOptions.merge())
            .await()
    }

    private fun appointment(document: DocumentSnapshot): Appointment? {
        val studentID = document.getString("studentID") ?: return null
        val counselorID = document.getString("counselorID") ?: return null
        val scheduledAt = document.getDate("scheduledAt") ?: return null
        val status = AppointmentStatus.fromRaw(document.getString("status")) ?: return null
        return Appointment(
            id = document.id,
            studentID = studentID,
            studentName = document.getString("studentName") ?: "Student",
            counselorID = counselorID,
            counselorName = document.getString("counselorName") ?: "Counselor",
            scheduledAt = scheduledAt,
            status = status,
            createdAt = document.getDate("createdAt") ?: Date()
        )
    }
}
