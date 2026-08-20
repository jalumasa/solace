package com.jonathanalumasa.solace.ui.today

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Chat
import androidx.compose.material.icons.filled.Air
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Spa
import androidx.compose.material.icons.filled.SportsEsports
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.jonathanalumasa.solace.model.MoodLevel
import com.jonathanalumasa.solace.ui.AppTab
import com.jonathanalumasa.solace.ui.shared.ScreenTitle
import com.jonathanalumasa.solace.ui.shared.SolaceCard
import com.jonathanalumasa.solace.ui.theme.SolaceColors
import com.jonathanalumasa.solace.ui.theme.Spacing
import com.jonathanalumasa.solace.ui.theme.color
import com.jonathanalumasa.solace.viewmodel.TodayViewModel

@Composable
fun TodayScreen(
    viewModel: TodayViewModel,
    onSelectTab: (AppTab) -> Unit,
    onOpenBreathing: () -> Unit
) {
    // Observed so the streak/check-in state recomposes when Firestore pushes.
    val moodHistory by viewModel.moodHistory.collectAsStateWithLifecycle()
    val gratitudeEntries by viewModel.gratitudeEntries.collectAsStateWithLifecycle()
    val isSubmitting by viewModel.isSubmittingMood.collectAsStateWithLifecycle()

    val streak = viewModel.streak
    val checkedIn = viewModel.hasCheckedInToday

    Column(verticalArrangement = Arrangement.spacedBy(Spacing.large)) {
        ScreenTitle("Today")

        Text(
            viewModel.greeting,
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        SolaceCard {
            if (checkedIn) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(Spacing.small)
                ) {
                    Icon(
                        Icons.Filled.CheckCircle,
                        contentDescription = null,
                        tint = SolaceColors.Leaf
                    )
                    Text("You checked in today", style = MaterialTheme.typography.titleMedium)
                }
            } else {
                Text("How are you feeling today?", style = MaterialTheme.typography.titleMedium)
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = Spacing.medium),
                    horizontalArrangement = Arrangement.spacedBy(Spacing.xSmall)
                ) {
                    MoodLevel.entries.forEach { mood ->
                        MoodButton(
                            mood = mood,
                            enabled = !isSubmitting,
                            onClick = { viewModel.logMood(mood) },
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }
        }

        if (streak > 0) {
            SolaceCard {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(Spacing.small)
                ) {
                    Icon(
                        Icons.Filled.LocalFireDepartment,
                        contentDescription = null,
                        tint = SolaceColors.Warm
                    )
                    Column {
                        Text("$streak-day streak", style = MaterialTheme.typography.titleMedium)
                        Text(
                            "Keep journaling to grow it.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }

        Row(horizontalArrangement = Arrangement.spacedBy(Spacing.small)) {
            QuickAction("Talk", Icons.AutoMirrored.Filled.Chat, SolaceColors.Sky, Modifier.weight(1f)) {
                onSelectTab(AppTab.TALK)
            }
            QuickAction("Wellness", Icons.Filled.Spa, SolaceColors.Leaf, Modifier.weight(1f)) {
                onSelectTab(AppTab.WELLNESS)
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(Spacing.small)) {
            QuickAction("Games", Icons.Filled.SportsEsports, SolaceColors.Secondary, Modifier.weight(1f)) {
                onSelectTab(AppTab.GAMES)
            }
            QuickAction("Breathe", Icons.Filled.Air, SolaceColors.Coral, Modifier.weight(1f)) {
                onOpenBreathing()
            }
        }

        if (moodHistory.isEmpty() && gratitudeEntries.isEmpty()) {
            Text(
                "Your check-ins and journal entries will build a streak here.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun MoodButton(
    mood: MoodLevel,
    enabled: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier,
        contentPadding = androidx.compose.foundation.layout.PaddingValues(
            horizontal = 2.dp,
            vertical = Spacing.small
        ),
        colors = ButtonDefaults.buttonColors(
            containerColor = mood.color.copy(alpha = 0.18f),
            contentColor = MaterialTheme.colorScheme.onSurface
        )
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(mood.emoji, style = MaterialTheme.typography.titleLarge)
            Text(
                mood.label,
                style = MaterialTheme.typography.labelSmall,
                textAlign = TextAlign.Center
            )
        }
    }
}

@Composable
private fun QuickAction(
    title: String,
    icon: ImageVector,
    tint: Color,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        modifier = modifier,
        // A translucent surface rather than a tinted one: over the ambient
        // background a 15%-alpha tint just reads as mud, so the icon carries
        // the colour and the plate stays neutral.
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.62f),
            contentColor = MaterialTheme.colorScheme.onSurface
        ),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(Spacing.medium)
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(28.dp))
            Text(title, style = MaterialTheme.typography.labelLarge)
        }
    }
}
