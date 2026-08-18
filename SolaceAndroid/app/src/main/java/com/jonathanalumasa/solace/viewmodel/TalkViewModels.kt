package com.jonathanalumasa.solace.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jonathanalumasa.solace.model.Conversation
import com.jonathanalumasa.solace.model.Message
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.service.MessagingService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/** Mirrors `SolaceCore.ConversationListViewModel`. */
class ConversationListViewModel(
    private val currentUser: User,
    private val messagingService: MessagingService
) : ViewModel() {

    private val _conversations = MutableStateFlow<List<Conversation>>(emptyList())
    val conversations: StateFlow<List<Conversation>> = _conversations.asStateFlow()

    private val _counselors = MutableStateFlow<List<User>>(emptyList())
    val counselors: StateFlow<List<User>> = _counselors.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        viewModelScope.launch {
            messagingService.observeConversations(currentUser.id).collect {
                _conversations.value = it
            }
        }
        loadCounselors()
    }

    fun clearError() {
        _errorMessage.value = null
    }

    fun loadCounselors() {
        if (currentUser.role != Role.STUDENT) return
        viewModelScope.launch {
            _isLoading.value = true
            try {
                _counselors.value = messagingService.fetchCounselors()
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't load counselors. Please try again."
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun conversationWith(counselor: User): Conversation? =
        _conversations.value.firstOrNull { it.counselorID == counselor.id }

    /** Finds or creates the conversation, then hands it back for navigation. */
    fun selectCounselor(counselor: User, onReady: (Conversation) -> Unit) {
        conversationWith(counselor)?.let {
            onReady(it)
            return
        }
        viewModelScope.launch {
            try {
                onReady(
                    messagingService.startConversation(
                        studentID = currentUser.id,
                        studentName = currentUser.displayName,
                        counselorID = counselor.id,
                        counselorName = counselor.displayName
                    )
                )
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't start conversation. Please try again."
            }
        }
    }
}

/** Mirrors `SolaceCore.ChatViewModel`. */
class ChatViewModel(
    private val conversationID: String,
    private val currentUserID: String,
    private val messagingService: MessagingService
) : ViewModel() {

    private val _messages = MutableStateFlow<List<Message>>(emptyList())
    val messages: StateFlow<List<Message>> = _messages.asStateFlow()

    private val _draftText = MutableStateFlow("")
    val draftText: StateFlow<String> = _draftText.asStateFlow()

    private val _isSending = MutableStateFlow(false)
    val isSending: StateFlow<Boolean> = _isSending.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        viewModelScope.launch {
            messagingService.observeMessages(conversationID).collect { _messages.value = it }
        }
    }

    fun updateDraft(value: String) {
        _draftText.value = value
    }

    fun isFromCurrentUser(message: Message): Boolean = message.senderID == currentUserID

    fun send() {
        val text = _draftText.value.trim()
        if (text.isEmpty()) return
        _draftText.value = ""
        viewModelScope.launch {
            _isSending.value = true
            try {
                messagingService.sendMessage(conversationID, currentUserID, text)
            } catch (error: Exception) {
                _errorMessage.value = "Message failed to send. Please try again."
                _draftText.value = text
            } finally {
                _isSending.value = false
            }
        }
    }
}

/** Mirrors `SolaceCore.AIChatViewModel`. Session-local — nothing is persisted. */
class AIChatViewModel(
    private val aiChatService: com.jonathanalumasa.solace.service.AIChatService
) : ViewModel() {

    private val _messages = MutableStateFlow(
        listOf(
            com.jonathanalumasa.solace.model.AIChatMessage(
                role = com.jonathanalumasa.solace.model.AIChatRole.ASSISTANT,
                text = "Hi, I'm here to listen. What's on your mind today?"
            )
        )
    )
    val messages: StateFlow<List<com.jonathanalumasa.solace.model.AIChatMessage>> =
        _messages.asStateFlow()

    private val _draftText = MutableStateFlow("")
    val draftText: StateFlow<String> = _draftText.asStateFlow()

    private val _isSending = MutableStateFlow(false)
    val isSending: StateFlow<Boolean> = _isSending.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    fun updateDraft(value: String) {
        _draftText.value = value
    }

    fun send() {
        val text = _draftText.value.trim()
        if (text.isEmpty() || _isSending.value) return
        val history = _messages.value
        _draftText.value = ""
        _messages.value = history + com.jonathanalumasa.solace.model.AIChatMessage(
            role = com.jonathanalumasa.solace.model.AIChatRole.USER,
            text = text
        )

        viewModelScope.launch {
            _isSending.value = true
            try {
                val reply = aiChatService.sendMessage(history, text)
                _messages.value = _messages.value + com.jonathanalumasa.solace.model.AIChatMessage(
                    role = com.jonathanalumasa.solace.model.AIChatRole.ASSISTANT,
                    text = reply
                )
            } catch (error: Exception) {
                _errorMessage.value = "The assistant is unavailable right now."
            } finally {
                _isSending.value = false
            }
        }
    }
}
