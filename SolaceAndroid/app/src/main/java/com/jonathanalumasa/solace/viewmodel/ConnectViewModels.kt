package com.jonathanalumasa.solace.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jonathanalumasa.solace.model.Appointment
import com.jonathanalumasa.solace.model.AppointmentStatus
import com.jonathanalumasa.solace.model.CircleMessage
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.SupportCircle
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.service.AppointmentService
import com.jonathanalumasa.solace.service.CircleService
import com.jonathanalumasa.solace.service.MessagingService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.Date

/** Mirrors `SolaceCore.AppointmentListViewModel`. */
class AppointmentListViewModel(
    private val currentUser: User,
    private val appointmentService: AppointmentService,
    private val messagingService: MessagingService
) : ViewModel() {

    private val _appointments = MutableStateFlow<List<Appointment>>(emptyList())
    val appointments: StateFlow<List<Appointment>> = _appointments.asStateFlow()

    private val _counselors = MutableStateFlow<List<User>>(emptyList())
    val counselors: StateFlow<List<User>> = _counselors.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        viewModelScope.launch {
            appointmentService.observeAppointments(currentUser.id).collect {
                _appointments.value = it
            }
        }
        loadCounselors()
    }

    fun clearError() {
        _errorMessage.value = null
    }

    val pending: List<Appointment>
        get() = _appointments.value.filter { it.status == AppointmentStatus.PENDING }

    val upcoming: List<Appointment>
        get() = _appointments.value.filter {
            it.status == AppointmentStatus.CONFIRMED && !it.scheduledAt.before(Date())
        }

    val past: List<Appointment>
        get() = _appointments.value.filter {
            it.status != AppointmentStatus.PENDING &&
                (it.status != AppointmentStatus.CONFIRMED || it.scheduledAt.before(Date()))
        }

    fun loadCounselors() {
        if (currentUser.role != Role.STUDENT) return
        viewModelScope.launch {
            try {
                _counselors.value = messagingService.fetchCounselors()
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't load counselors. Please try again."
            }
        }
    }

    fun requestAppointment(counselor: User, at: Date) {
        if (currentUser.role != Role.STUDENT) return
        viewModelScope.launch {
            try {
                appointmentService.requestAppointment(
                    studentID = currentUser.id,
                    studentName = currentUser.displayName,
                    counselorID = counselor.id,
                    counselorName = counselor.displayName,
                    scheduledAt = at
                )
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't request that appointment. Please try again."
            }
        }
    }

    fun respond(appointment: Appointment, status: AppointmentStatus) {
        if (currentUser.role != Role.COUNSELOR || appointment.counselorID != currentUser.id) return
        updateStatus(appointment.id, status)
    }

    fun cancel(appointment: Appointment) {
        if (appointment.studentID != currentUser.id) return
        updateStatus(appointment.id, AppointmentStatus.CANCELLED)
    }

    private fun updateStatus(appointmentID: String, status: AppointmentStatus) {
        viewModelScope.launch {
            try {
                appointmentService.updateStatus(appointmentID, status)
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't update that appointment. Please try again."
            }
        }
    }
}

/** Mirrors `SolaceCore.CircleListViewModel`. */
class CircleListViewModel(
    private val currentUserID: String,
    private val circleService: CircleService
) : ViewModel() {

    private val _circles = MutableStateFlow<List<SupportCircle>>(emptyList())
    val circles: StateFlow<List<SupportCircle>> = _circles.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        viewModelScope.launch {
            circleService.observeCircles().collect { _circles.value = it }
        }
    }

    fun clearError() {
        _errorMessage.value = null
    }

    fun myCircles(all: List<SupportCircle>) = all.filter { it.isMember(currentUserID) }

    fun availableCircles(all: List<SupportCircle>) = all.filter { !it.isMember(currentUserID) }

    fun join(circle: SupportCircle) {
        viewModelScope.launch {
            try {
                circleService.join(circle.id, currentUserID)
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't join that circle. Please try again."
            }
        }
    }

    fun leave(circle: SupportCircle) {
        viewModelScope.launch {
            try {
                circleService.leave(circle.id, currentUserID)
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't leave that circle. Please try again."
            }
        }
    }
}

/** Mirrors `SolaceCore.CircleChatViewModel`. */
class CircleChatViewModel(
    private val circleID: String,
    private val currentUser: User,
    private val circleService: CircleService
) : ViewModel() {

    private val _messages = MutableStateFlow<List<CircleMessage>>(emptyList())
    val messages: StateFlow<List<CircleMessage>> = _messages.asStateFlow()

    private val _draftText = MutableStateFlow("")
    val draftText: StateFlow<String> = _draftText.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        viewModelScope.launch {
            circleService.observeMessages(circleID).collect { _messages.value = it }
        }
    }

    fun updateDraft(value: String) {
        _draftText.value = value
    }

    fun isFromCurrentUser(message: CircleMessage): Boolean = message.senderID == currentUser.id

    fun send() {
        val text = _draftText.value.trim()
        if (text.isEmpty()) return
        _draftText.value = ""
        viewModelScope.launch {
            try {
                circleService.sendMessage(circleID, currentUser.id, currentUser.displayName, text)
            } catch (error: Exception) {
                _errorMessage.value = "Message failed to send. Please try again."
                _draftText.value = text
            }
        }
    }
}
