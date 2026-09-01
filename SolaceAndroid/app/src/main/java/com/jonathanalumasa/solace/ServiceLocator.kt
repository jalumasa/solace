package com.jonathanalumasa.solace

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.jonathanalumasa.solace.service.AIChatService
import com.jonathanalumasa.solace.service.AppointmentService
import com.jonathanalumasa.solace.service.AuthService
import com.jonathanalumasa.solace.service.CircleService
import com.jonathanalumasa.solace.service.JournalService
import com.jonathanalumasa.solace.service.MessagingService
import com.jonathanalumasa.solace.service.MoodService
import com.jonathanalumasa.solace.service.ResourceService
import com.jonathanalumasa.solace.service.firebase.CloudFunctionAIChatService
import com.jonathanalumasa.solace.service.firebase.FirebaseAuthService
import com.jonathanalumasa.solace.service.firebase.FirestoreAppointmentService
import com.jonathanalumasa.solace.service.firebase.FirestoreCircleService
import com.jonathanalumasa.solace.service.firebase.FirestoreJournalService
import com.jonathanalumasa.solace.service.firebase.FirestoreMessagingService
import com.jonathanalumasa.solace.service.firebase.FirestoreMoodService
import com.jonathanalumasa.solace.service.firebase.FirestoreResourceService

/**
 * Plain constructor injection, no DI framework — mirroring the iOS app, where
 * views construct their concrete `FirestoreXService` directly. ViewModels
 * depend only on the interfaces, so tests substitute fakes freely.
 */
object ServiceLocator {
    val authService: AuthService by lazy { FirebaseAuthService() }
    val messagingService: MessagingService by lazy { FirestoreMessagingService() }
    val moodService: MoodService by lazy { FirestoreMoodService() }
    val journalService: JournalService by lazy { FirestoreJournalService() }
    val appointmentService: AppointmentService by lazy { FirestoreAppointmentService() }
    val circleService: CircleService by lazy { FirestoreCircleService() }
    val resourceService: ResourceService by lazy { FirestoreResourceService() }
    val aiChatService: AIChatService by lazy { CloudFunctionAIChatService() }
}

/** Builds a [ViewModelProvider.Factory] from a plain constructor call. */
fun <VM : ViewModel> viewModelFactory(initializer: () -> VM): ViewModelProvider.Factory =
    object : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T = initializer() as T
    }
