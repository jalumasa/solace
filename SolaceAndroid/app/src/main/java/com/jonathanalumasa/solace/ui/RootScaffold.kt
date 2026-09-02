package com.jonathanalumasa.solace.ui

import androidx.activity.compose.BackHandler
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Spa
import androidx.compose.material.icons.filled.SportsEsports
import androidx.compose.material.icons.filled.WbSunny
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.lifecycle.viewmodel.compose.viewModel
import com.jonathanalumasa.solace.ServiceLocator
import com.jonathanalumasa.solace.model.Conversation
import com.jonathanalumasa.solace.model.RelaxationExercise
import com.jonathanalumasa.solace.model.ResourceItem
import com.jonathanalumasa.solace.model.Role
import com.jonathanalumasa.solace.model.SupportCircle
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.ui.connect.AppointmentsScreen
import com.jonathanalumasa.solace.ui.connect.CirclesScreen
import com.jonathanalumasa.solace.ui.games.GameScreen
import com.jonathanalumasa.solace.ui.games.GamesScreen
import com.jonathanalumasa.solace.ui.profile.ReminderSettings
import com.jonathanalumasa.solace.ui.games.SolaceGame
import com.jonathanalumasa.solace.ui.shared.AmbientBackground
import com.jonathanalumasa.solace.ui.shared.CrisisResourceList
import com.jonathanalumasa.solace.ui.shared.CrisisSheet
import com.jonathanalumasa.solace.ui.shared.ScreenTitle
import com.jonathanalumasa.solace.ui.shared.SolaceCard
import com.jonathanalumasa.solace.ui.shared.SosButton
import com.jonathanalumasa.solace.ui.talk.AIChatScreen
import com.jonathanalumasa.solace.ui.talk.Bubble
import com.jonathanalumasa.solace.ui.talk.ChatScreen
import com.jonathanalumasa.solace.ui.talk.MessageThread
import com.jonathanalumasa.solace.ui.talk.TalkScreen
import com.jonathanalumasa.solace.ui.theme.Ambient
import com.jonathanalumasa.solace.ui.theme.Spacing
import com.jonathanalumasa.solace.ui.today.TodayScreen
import com.jonathanalumasa.solace.ui.wellness.ArticleScreen
import com.jonathanalumasa.solace.ui.wellness.RelaxationScreen
import com.jonathanalumasa.solace.ui.wellness.WellnessScreen
import com.jonathanalumasa.solace.viewModelFactory
import com.jonathanalumasa.solace.viewmodel.AIChatViewModel
import com.jonathanalumasa.solace.viewmodel.AppointmentListViewModel
import com.jonathanalumasa.solace.viewmodel.ChatViewModel
import com.jonathanalumasa.solace.viewmodel.CircleChatViewModel
import com.jonathanalumasa.solace.viewmodel.CircleListViewModel
import com.jonathanalumasa.solace.viewmodel.ConversationListViewModel
import com.jonathanalumasa.solace.viewmodel.GratitudeGardenViewModel
import com.jonathanalumasa.solace.viewmodel.ResourceLibraryViewModel
import com.jonathanalumasa.solace.viewmodel.TodayViewModel
import androidx.compose.foundation.layout.ColumnScope
import androidx.lifecycle.compose.collectAsStateWithLifecycle

/** Mirrors the iOS `AppTab` enum and its 5-tab information architecture. */
enum class AppTab(val label: String, val icon: ImageVector) {
    TODAY("Today", Icons.Filled.WbSunny),
    TALK("Talk", Icons.AutoMirrored.Filled.Chat),
    WELLNESS("Wellness", Icons.Filled.Spa),
    GAMES("Games", Icons.Filled.SportsEsports),
    PROFILE("Profile", Icons.Filled.AccountCircle)
}

/** A pushed detail screen layered over the current tab. */
private sealed interface Destination {
    data object AIChat : Destination
    data object Appointments : Destination
    data object Circles : Destination
    data class Chat(val conversation: Conversation) : Destination
    data class CircleChat(val circle: SupportCircle) : Destination
    data class Relaxation(val exercise: RelaxationExercise) : Destination
    data class Article(val article: ResourceItem) : Destination
    data class Game(val game: SolaceGame) : Destination
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RootScaffold(currentUser: User, onSignOut: () -> Unit) {
    var selectedTab by remember { mutableStateOf(AppTab.TODAY) }
    var destination by remember { mutableStateOf<Destination?>(null) }
    var showCrisis by remember { mutableStateOf(false) }

    val todayViewModel: TodayViewModel = viewModel(
        key = "today-${currentUser.id}",
        factory = viewModelFactory {
            TodayViewModel(currentUser, ServiceLocator.moodService, ServiceLocator.journalService)
        }
    )
    val resourceViewModel: ResourceLibraryViewModel = viewModel(
        key = "resources",
        factory = viewModelFactory { ResourceLibraryViewModel(ServiceLocator.resourceService) }
    )
    val gratitudeViewModel: GratitudeGardenViewModel = viewModel(
        key = "gratitude-${currentUser.id}",
        factory = viewModelFactory {
            GratitudeGardenViewModel(currentUser.id, ServiceLocator.journalService)
        }
    )
    val conversationViewModel: ConversationListViewModel = viewModel(
        key = "conversations-${currentUser.id}",
        factory = viewModelFactory {
            ConversationListViewModel(currentUser, ServiceLocator.messagingService)
        }
    )

    BackHandler(enabled = destination != null) { destination = null }

    // Each tab carries its own ambient palette, mirroring iOS. The gradient
    // cross-fades on tab change rather than cutting, so switching tabs feels
    // like moving through one space instead of swapping screens.
    val palette = when (selectedTab) {
        AppTab.TODAY -> Ambient.today
        AppTab.TALK -> Ambient.talk
        AppTab.WELLNESS -> Ambient.wellness
        AppTab.GAMES -> Ambient.games
        AppTab.PROFILE -> Ambient.profile
    }

    Box(Modifier.fillMaxSize()) {
        Crossfade(targetState = palette, animationSpec = tween(600), label = "ambient-tab") {
            AmbientBackground(colors = it)
        }

        Scaffold(
            containerColor = Color.Transparent,
            topBar = {
                TopAppBar(
                    title = { Text("") },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = Color.Transparent
                    ),
                    navigationIcon = {
                        if (destination != null) {
                            IconButton(onClick = { destination = null }) {
                                Icon(
                                    Icons.AutoMirrored.Filled.ArrowBack,
                                    contentDescription = "Back"
                                )
                            }
                        }
                    },
                    actions = { SosButton { showCrisis = true } }
                )
            },
            bottomBar = {
                NavigationBar(
                    containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.75f)
                ) {
                    AppTab.entries.forEach { tab ->
                        NavigationBarItem(
                            selected = selectedTab == tab,
                            onClick = {
                                selectedTab = tab
                                destination = null
                            },
                            icon = { Icon(tab.icon, contentDescription = tab.label) },
                            label = { Text(tab.label) }
                        )
                    }
                }
            }
        ) { padding ->
        // Chat destinations own a LazyColumn, so they must NOT sit inside a
        // verticalScroll — nesting two vertical scrollers crashes Compose.
        // Everything else opts into scrolling via [Scrollable].
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = Spacing.large)
        ) {
            when (val current = destination) {
                null -> Scrollable {
                    TabContent(
                        tab = selectedTab,
                        currentUser = currentUser,
                        todayViewModel = todayViewModel,
                        conversationViewModel = conversationViewModel,
                        resourceViewModel = resourceViewModel,
                        gratitudeViewModel = gratitudeViewModel,
                        onSelectTab = { selectedTab = it },
                        onNavigate = { destination = it },
                        onSignOut = onSignOut
                    )
                }

                is Destination.AIChat -> {
                    val vm: AIChatViewModel = viewModel(
                        factory = viewModelFactory { AIChatViewModel(ServiceLocator.aiChatService) }
                    )
                    AIChatScreen(vm)
                }

                is Destination.Chat -> {
                    val vm: ChatViewModel = viewModel(
                        key = "chat-${current.conversation.id}",
                        factory = viewModelFactory {
                            ChatViewModel(
                                current.conversation.id,
                                currentUser.id,
                                ServiceLocator.messagingService
                            )
                        }
                    )
                    ChatScreen(current.conversation, currentUser, vm)
                }

                is Destination.Appointments -> Scrollable {
                    val vm: AppointmentListViewModel = viewModel(
                        key = "appointments-${currentUser.id}",
                        factory = viewModelFactory {
                            AppointmentListViewModel(
                                currentUser,
                                ServiceLocator.appointmentService,
                                ServiceLocator.messagingService
                            )
                        }
                    )
                    AppointmentsScreen(currentUser, vm)
                }

                is Destination.Circles -> Scrollable {
                    val vm: CircleListViewModel = viewModel(
                        key = "circles-${currentUser.id}",
                        factory = viewModelFactory {
                            CircleListViewModel(currentUser.id, ServiceLocator.circleService)
                        }
                    )
                    CirclesScreen(vm) { destination = Destination.CircleChat(it) }
                }

                is Destination.CircleChat -> {
                    val vm: CircleChatViewModel = viewModel(
                        key = "circle-chat-${current.circle.id}",
                        factory = viewModelFactory {
                            CircleChatViewModel(
                                current.circle.id,
                                currentUser,
                                ServiceLocator.circleService
                            )
                        }
                    )
                    CircleChatContent(current.circle, vm)
                }

                is Destination.Relaxation -> Scrollable { RelaxationScreen(current.exercise) }
                is Destination.Article -> Scrollable { ArticleScreen(current.article) }
                is Destination.Game -> Scrollable { GameScreen(current.game, gratitudeViewModel) }
            }
            }
        }
    }

    if (showCrisis) {
        CrisisSheet(onDismiss = { showCrisis = false })
    }
}

/** Vertical-scrolling body used by every screen that isn't a chat thread. */
@Composable
private fun Scrollable(content: @Composable ColumnScope.() -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(Spacing.medium),
        content = content
    )
}

@Composable
private fun CircleChatContent(circle: SupportCircle, viewModel: CircleChatViewModel) {
    val messages by viewModel.messages.collectAsStateWithLifecycle()
    val draft by viewModel.draftText.collectAsStateWithLifecycle()
    val error by viewModel.errorMessage.collectAsStateWithLifecycle()

    MessageThread(
        title = circle.name,
        bubbles = messages.map {
            Bubble(it.id, it.text, viewModel.isFromCurrentUser(it), it.senderName)
        },
        draft = draft,
        error = error,
        onDraftChange = viewModel::updateDraft,
        onSend = viewModel::send
    )
}

@Composable
private fun TabContent(
    tab: AppTab,
    currentUser: User,
    todayViewModel: TodayViewModel,
    conversationViewModel: ConversationListViewModel,
    resourceViewModel: ResourceLibraryViewModel,
    gratitudeViewModel: GratitudeGardenViewModel,
    onSelectTab: (AppTab) -> Unit,
    onNavigate: (Destination) -> Unit,
    onSignOut: () -> Unit
) {
    when (tab) {
        AppTab.TODAY -> TodayScreen(
            viewModel = todayViewModel,
            onSelectTab = onSelectTab,
            onOpenBreathing = {
                onNavigate(Destination.Relaxation(RelaxationExercise.breathingExercises.first()))
            }
        )

        AppTab.TALK -> TalkScreen(
            currentUser = currentUser,
            viewModel = conversationViewModel,
            onOpenAIChat = { onNavigate(Destination.AIChat) },
            onOpenAppointments = { onNavigate(Destination.Appointments) },
            onOpenCircles = { onNavigate(Destination.Circles) },
            onOpenConversation = { onNavigate(Destination.Chat(it)) }
        )

        AppTab.WELLNESS -> WellnessScreen(
            todayViewModel = todayViewModel,
            resourceViewModel = resourceViewModel,
            onOpenExercise = { onNavigate(Destination.Relaxation(it)) },
            onOpenArticle = { onNavigate(Destination.Article(it)) }
        )

        AppTab.GAMES -> GamesScreen(onOpenGame = { onNavigate(Destination.Game(it)) })

        AppTab.PROFILE -> ProfileTab(
            currentUser = currentUser,
            todayViewModel = todayViewModel,
            onSignOut = onSignOut
        )
    }
}

@Composable
private fun ProfileTab(
    currentUser: User,
    todayViewModel: TodayViewModel,
    onSignOut: () -> Unit
) {
    val moodHistory by todayViewModel.moodHistory.collectAsStateWithLifecycle()

    Column(verticalArrangement = Arrangement.spacedBy(Spacing.large)) {
        ScreenTitle("Profile")

        SolaceCard {
            LabeledRow("Name", currentUser.displayName)
            LabeledRow("Email", currentUser.email)
            LabeledRow("Role", if (currentUser.role == Role.STUDENT) "Student" else "Counselor")

            if (currentUser.role == Role.STUDENT) {
                currentUser.major?.let { LabeledRow("Major", it) }
                currentUser.academicYear?.let { LabeledRow("Academic year", it.label) }
                currentUser.age?.let { LabeledRow("Age", it.toString()) }
            } else {
                currentUser.bio?.takeIf { it.isNotBlank() }?.let { LabeledRow("Bio", it) }
            }
        }

        Text("Your Progress", style = MaterialTheme.typography.titleSmall)
        SolaceCard {
            LabeledRow(
                "Current streak",
                "${todayViewModel.streak} day${if (todayViewModel.streak == 1) "" else "s"}"
            )
            LabeledRow("Check-ins logged", moodHistory.size.toString())
        }

        ReminderSettings()

        Text("Crisis Support", style = MaterialTheme.typography.titleSmall)
        SolaceCard { CrisisResourceList() }

        OutlinedButton(onClick = onSignOut) { Text("Sign Out") }
    }
}

@Composable
private fun LabeledRow(label: String, value: String) {
    Column(Modifier.padding(vertical = Spacing.xSmall)) {
        Text(
            label,
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(value, style = MaterialTheme.typography.bodyLarge)
    }
}
