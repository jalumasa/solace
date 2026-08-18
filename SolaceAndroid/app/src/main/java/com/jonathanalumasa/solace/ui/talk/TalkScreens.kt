package com.jonathanalumasa.solace.ui.talk

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Groups
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.jonathanalumasa.solace.model.Conversation
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.ui.shared.IconRow
import com.jonathanalumasa.solace.ui.shared.ScreenTitle
import com.jonathanalumasa.solace.ui.shared.SolaceCard
import com.jonathanalumasa.solace.ui.theme.SolaceColors
import com.jonathanalumasa.solace.ui.theme.Spacing
import com.jonathanalumasa.solace.viewmodel.AIChatViewModel
import com.jonathanalumasa.solace.viewmodel.ChatViewModel
import com.jonathanalumasa.solace.viewmodel.ConversationListViewModel

@Composable
fun TalkScreen(
    currentUser: User,
    viewModel: ConversationListViewModel,
    onOpenAIChat: () -> Unit,
    onOpenAppointments: () -> Unit,
    onOpenCircles: () -> Unit,
    onOpenConversation: (Conversation) -> Unit
) {
    val counselors by viewModel.counselors.collectAsStateWithLifecycle()
    val conversations by viewModel.conversations.collectAsStateWithLifecycle()
    val isLoading by viewModel.isLoading.collectAsStateWithLifecycle()

    Column(verticalArrangement = Arrangement.spacedBy(Spacing.large)) {
        ScreenTitle("Talk")

        SolaceCard {
            Box(Modifier.clickable { onOpenAIChat() }) {
                IconRow(
                    title = "AI Companion",
                    subtitle = "Available 24/7 for general support",
                    icon = Icons.Filled.AutoAwesome,
                    tint = SolaceColors.Secondary
                )
            }
        }

        Text("Connect", style = MaterialTheme.typography.titleSmall)
        SolaceCard {
            Box(Modifier.clickable { onOpenAppointments() }) {
                IconRow(
                    title = "Appointments",
                    subtitle = "Schedule time with a counselor",
                    icon = Icons.Filled.CalendarMonth,
                    tint = SolaceColors.Sky
                )
            }
            HorizontalDivider()
            Box(Modifier.clickable { onOpenCircles() }) {
                IconRow(
                    title = "Support Circles",
                    subtitle = "Join a peer group on a shared topic",
                    icon = Icons.Filled.Groups,
                    tint = SolaceColors.Leaf
                )
            }
        }

        if (currentUser.role == Role.STUDENT) {
            Text("Counselors", style = MaterialTheme.typography.titleSmall)
            when {
                isLoading && counselors.isEmpty() -> CircularProgressIndicator()
                counselors.isEmpty() -> EmptyNote("No counselors available yet.")
                else -> SolaceCard {
                    counselors.forEachIndexed { index, counselor ->
                        CounselorRow(
                            counselor = counselor,
                            preview = viewModel.conversationWith(counselor)?.lastMessageText,
                            onClick = { viewModel.selectCounselor(counselor, onOpenConversation) }
                        )
                        if (index != counselors.lastIndex) HorizontalDivider()
                    }
                }
            }
        } else {
            Text("Conversations", style = MaterialTheme.typography.titleSmall)
            if (conversations.isEmpty()) {
                EmptyNote("Conversations from students will appear here.")
            } else {
                SolaceCard {
                    conversations.forEachIndexed { index, conversation ->
                        Column(
                            Modifier
                                .fillMaxWidth()
                                .clickable { onOpenConversation(conversation) }
                                .padding(vertical = Spacing.small)
                        ) {
                            Text(
                                conversation.otherParticipantName(currentUser.id),
                                style = MaterialTheme.typography.titleMedium
                            )
                            Text(
                                conversation.lastMessageText ?: "No messages yet",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                maxLines = 1
                            )
                        }
                        if (index != conversations.lastIndex) HorizontalDivider()
                    }
                }
            }
        }
    }
}

@Composable
private fun EmptyNote(text: String) {
    Text(
        text,
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )
}

@Composable
private fun CounselorRow(counselor: User, preview: String?, onClick: () -> Unit) {
    // Skip common honorifics so "Dr. Maya Chen" and "Dr. Priya Nair" don't both show "D".
    val initial = remember(counselor.displayName) {
        var name = counselor.displayName
        listOf("Dr. ", "Dr ", "Mr. ", "Mrs. ", "Ms. ").forEach { prefix ->
            if (name.startsWith(prefix)) name = name.removePrefix(prefix)
        }
        name.take(1)
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(vertical = Spacing.small),
        horizontalArrangement = Arrangement.spacedBy(Spacing.medium),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .background(SolaceColors.Secondary.copy(alpha = 0.25f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Text(
                initial,
                style = MaterialTheme.typography.titleMedium,
                color = SolaceColors.Secondary
            )
        }
        Column {
            Text(counselor.displayName, style = MaterialTheme.typography.titleMedium)
            Text(
                preview ?: counselor.bio?.takeIf { it.isNotBlank() } ?: "Tap to start a conversation",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 2
            )
        }
    }
}

@Composable
fun ChatScreen(conversation: Conversation, currentUser: User, viewModel: ChatViewModel) {
    val messages by viewModel.messages.collectAsStateWithLifecycle()
    val draft by viewModel.draftText.collectAsStateWithLifecycle()
    val error by viewModel.errorMessage.collectAsStateWithLifecycle()

    MessageThread(
        title = conversation.otherParticipantName(currentUser.id),
        bubbles = messages.map { Bubble(it.id, it.text, viewModel.isFromCurrentUser(it), null) },
        draft = draft,
        error = error,
        onDraftChange = viewModel::updateDraft,
        onSend = viewModel::send
    )
}

@Composable
fun AIChatScreen(viewModel: AIChatViewModel) {
    val messages by viewModel.messages.collectAsStateWithLifecycle()
    val draft by viewModel.draftText.collectAsStateWithLifecycle()
    val error by viewModel.errorMessage.collectAsStateWithLifecycle()
    val isSending by viewModel.isSending.collectAsStateWithLifecycle()

    MessageThread(
        title = "AI Companion",
        bubbles = messages.map {
            Bubble(
                it.id,
                it.text,
                it.role == com.jonathanalumasa.solace.model.AIChatRole.USER,
                null
            )
        },
        draft = draft,
        error = error,
        footnote = if (isSending) "Thinking…" else
            "Not a substitute for professional care. In a crisis, use the SOS button.",
        onDraftChange = viewModel::updateDraft,
        onSend = viewModel::send
    )
}

data class Bubble(
    val id: String,
    val text: String,
    val isFromCurrentUser: Boolean,
    val senderName: String?
)

/** Shared thread layout used by 1:1 chat, AI chat, and circle chat. */
@Composable
fun MessageThread(
    title: String,
    bubbles: List<Bubble>,
    draft: String,
    error: String?,
    onDraftChange: (String) -> Unit,
    onSend: () -> Unit,
    footnote: String? = null
) {
    val listState = rememberLazyListState()
    LaunchedEffect(bubbles.size) {
        if (bubbles.isNotEmpty()) listState.animateScrollToItem(bubbles.lastIndex)
    }

    Column(Modifier.fillMaxSize()) {
        ScreenTitle(title, Modifier.padding(bottom = Spacing.medium))

        LazyColumn(
            state = listState,
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(Spacing.small)
        ) {
            items(bubbles, key = { it.id }) { bubble -> MessageBubble(bubble) }
        }

        error?.let {
            Text(it, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
        }
        footnote?.let {
            Text(
                it,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth().padding(vertical = Spacing.xSmall)
            )
        }

        Row(
            Modifier.fillMaxWidth().padding(top = Spacing.small),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = draft,
                onValueChange = onDraftChange,
                placeholder = { Text("Message") },
                modifier = Modifier.weight(1f),
                maxLines = 4
            )
            IconButton(onClick = onSend, enabled = draft.isNotBlank()) {
                Icon(Icons.AutoMirrored.Filled.Send, contentDescription = "Send")
            }
        }
    }
}

@Composable
private fun MessageBubble(bubble: Bubble) {
    Row(
        Modifier.fillMaxWidth(),
        horizontalArrangement = if (bubble.isFromCurrentUser) Arrangement.End else Arrangement.Start
    ) {
        Column(horizontalAlignment = if (bubble.isFromCurrentUser) Alignment.End else Alignment.Start) {
            bubble.senderName?.takeIf { !bubble.isFromCurrentUser }?.let {
                Text(
                    it,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Box(
                Modifier
                    .background(
                        if (bubble.isFromCurrentUser) SolaceColors.Primary
                        else MaterialTheme.colorScheme.surfaceContainerHighest,
                        RoundedCornerShape(16.dp)
                    )
                    .padding(horizontal = Spacing.medium, vertical = Spacing.small)
            ) {
                Text(
                    bubble.text,
                    color = if (bubble.isFromCurrentUser) androidx.compose.ui.graphics.Color.White
                    else MaterialTheme.colorScheme.onSurface
                )
            }
        }
    }
}
