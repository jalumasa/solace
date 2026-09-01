package com.jonathanalumasa.solace.ui.wellness

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FilterChip
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.jonathanalumasa.solace.model.BreathingPattern
import com.jonathanalumasa.solace.model.MoodEntry
import com.jonathanalumasa.solace.model.RelaxationExercise
import com.jonathanalumasa.solace.model.RelaxationKind
import com.jonathanalumasa.solace.model.ResourceCategory
import com.jonathanalumasa.solace.model.ResourceItem
import com.jonathanalumasa.solace.ui.shared.ScreenTitle
import com.jonathanalumasa.solace.ui.shared.SolaceCard
import com.jonathanalumasa.solace.ui.theme.SolaceColors
import com.jonathanalumasa.solace.ui.theme.Spacing
import com.jonathanalumasa.solace.ui.theme.color
import com.jonathanalumasa.solace.viewmodel.ResourceLibraryViewModel
import com.jonathanalumasa.solace.viewmodel.TodayViewModel
import kotlinx.coroutines.delay

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun WellnessScreen(
    todayViewModel: TodayViewModel,
    resourceViewModel: ResourceLibraryViewModel,
    onOpenExercise: (RelaxationExercise) -> Unit,
    onOpenArticle: (ResourceItem) -> Unit
) {
    val moodHistory by todayViewModel.moodHistory.collectAsStateWithLifecycle()
    val resources by resourceViewModel.resources.collectAsStateWithLifecycle()
    val selectedCategory by resourceViewModel.selectedCategory.collectAsStateWithLifecycle()
    val isLoading by resourceViewModel.isLoading.collectAsStateWithLifecycle()

    Column(verticalArrangement = Arrangement.spacedBy(Spacing.large)) {
        ScreenTitle("Wellness")

        if (moodHistory.isNotEmpty()) {
            Text("Mood Insights", style = MaterialTheme.typography.titleSmall)
            SolaceCard { MoodHistoryChart(moodHistory) }
        }

        Text("Relaxation Exercises", style = MaterialTheme.typography.titleSmall)
        SolaceCard {
            RelaxationExercise.all.forEachIndexed { index, exercise ->
                Column(
                    Modifier
                        .fillMaxWidth()
                        .clickable { onOpenExercise(exercise) }
                        .padding(vertical = Spacing.small)
                ) {
                    Text(exercise.title, style = MaterialTheme.typography.titleMedium)
                    Text(
                        exercise.description,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                if (index != RelaxationExercise.all.lastIndex) HorizontalDivider()
            }
        }

        Text("Articles", style = MaterialTheme.typography.titleSmall)

        FlowRow(horizontalArrangement = Arrangement.spacedBy(Spacing.small)) {
            FilterChip(
                selected = selectedCategory == null,
                onClick = { resourceViewModel.selectCategory(null) },
                label = { Text("All") }
            )
            ResourceCategory.entries.forEach { category ->
                FilterChip(
                    selected = selectedCategory == category,
                    onClick = { resourceViewModel.selectCategory(category) },
                    label = { Text(category.displayName) }
                )
            }
        }

        val visible = resourceViewModel.filtered(resources, selectedCategory)
        when {
            isLoading && resources.isEmpty() -> CircularProgressIndicator()

            visible.isEmpty() -> Text(
                if (resources.isEmpty())
                    "No articles yet — they're seeded into Firestore, so this fills in " +
                        "once content is added."
                else "Nothing in this category yet.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            else -> SolaceCard {
                visible.forEachIndexed { index, article ->
                    Column(
                        Modifier
                            .fillMaxWidth()
                            .clickable { onOpenArticle(article) }
                            .padding(vertical = Spacing.small)
                    ) {
                        Text(article.title, style = MaterialTheme.typography.titleMedium)
                        Text(
                            article.summary,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 2
                        )
                    }
                    if (index != visible.lastIndex) HorizontalDivider()
                }
            }
        }
    }
}

@Composable
fun ArticleScreen(article: ResourceItem) {
    Column(verticalArrangement = Arrangement.spacedBy(Spacing.medium)) {
        ScreenTitle(article.title)
        Text(
            article.category.displayName,
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.primary
        )
        Text(
            article.summary,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        SolaceCard {
            Text(article.body, style = MaterialTheme.typography.bodyMedium)
        }
    }
}

/** Swift Charts equivalent — last 14 entries as a simple line + point plot. */
@Composable
private fun MoodHistoryChart(entries: List<MoodEntry>) {
    val recent = remember(entries) { entries.take(14).reversed() }
    if (recent.size < 2) {
        Text(
            "Check in a few more times to see your trend.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        return
    }

    Canvas(
        Modifier
            .fillMaxWidth()
            .height(160.dp)
            .padding(vertical = Spacing.small)
    ) {
        val stepX = if (recent.size > 1) size.width / (recent.size - 1) else size.width
        // Mood is 1...5; map onto the full height with a little breathing room.
        fun yFor(raw: Int): Float = size.height - ((raw - 1f) / 4f) * size.height

        val points = recent.mapIndexed { index, entry ->
            Offset(index * stepX, yFor(entry.mood.rawValue))
        }

        points.zipWithNext { a, b ->
            drawLine(
                color = SolaceColors.Primary,
                start = a,
                end = b,
                strokeWidth = 4f
            )
        }
        recent.forEachIndexed { index, entry ->
            drawCircle(
                color = entry.mood.color,
                radius = 7f,
                center = points[index]
            )
        }
    }
    Text(
        "Last ${recent.size} check-ins",
        style = MaterialTheme.typography.labelSmall,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )
}

@Composable
fun RelaxationScreen(exercise: RelaxationExercise) {
    Column(verticalArrangement = Arrangement.spacedBy(Spacing.large)) {
        ScreenTitle(exercise.title)
        Text(
            exercise.description,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        when (val kind = exercise.kind) {
            is RelaxationKind.Breathing -> BreathingSession(kind.pattern)
            is RelaxationKind.GroundingScript -> GroundingScript(kind.steps)
        }
    }
}

private enum class BreathPhase(val label: String) {
    INHALE("Breathe in"), HOLD("Hold"), EXHALE("Breathe out"), HOLD_AFTER("Hold")
}

@Composable
private fun BreathingSession(pattern: BreathingPattern) {
    var running by remember { mutableStateOf(false) }
    var phase by remember { mutableStateOf(BreathPhase.INHALE) }
    var secondsLeft by remember { mutableIntStateOf(pattern.inhale) }

    fun durationOf(p: BreathPhase) = when (p) {
        BreathPhase.INHALE -> pattern.inhale
        BreathPhase.HOLD -> pattern.hold
        BreathPhase.EXHALE -> pattern.exhale
        BreathPhase.HOLD_AFTER -> pattern.holdAfterExhale
    }

    // Zero-length phases are skipped, so 4-7-8 doesn't stall on its absent hold.
    fun nextPhase(from: BreathPhase): BreathPhase {
        var candidate = from
        repeat(BreathPhase.entries.size) {
            candidate = BreathPhase.entries[(candidate.ordinal + 1) % BreathPhase.entries.size]
            if (durationOf(candidate) > 0) return candidate
        }
        return from
    }

    LaunchedEffect(running) {
        while (running) {
            delay(1000)
            if (secondsLeft > 1) {
                secondsLeft -= 1
            } else {
                phase = nextPhase(phase)
                secondsLeft = durationOf(phase)
            }
        }
    }

    val scale by animateFloatAsState(
        targetValue = when (phase) {
            BreathPhase.INHALE -> 1f
            BreathPhase.HOLD -> 1f
            BreathPhase.EXHALE -> 0.55f
            BreathPhase.HOLD_AFTER -> 0.55f
        },
        animationSpec = tween(durationMillis = durationOf(phase).coerceAtLeast(1) * 1000),
        label = "breath"
    )

    Column(
        Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(Spacing.large)
    ) {
        Box(Modifier.height(220.dp).fillMaxWidth(), contentAlignment = Alignment.Center) {
            Canvas(Modifier.size(200.dp)) {
                drawCircle(
                    color = SolaceColors.Primary.copy(alpha = 0.25f),
                    radius = (size.minDimension / 2f) * scale
                )
                drawCircle(
                    color = SolaceColors.Primary,
                    radius = (size.minDimension / 2f) * scale,
                    style = androidx.compose.ui.graphics.drawscope.Stroke(width = 5f)
                )
            }
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(phase.label, style = MaterialTheme.typography.titleLarge)
                Text("$secondsLeft", style = MaterialTheme.typography.displaySmall)
            }
        }

        Button(onClick = {
            running = !running
            if (running) {
                phase = BreathPhase.INHALE
                secondsLeft = pattern.inhale
            }
        }) {
            Text(if (running) "Stop" else "Start")
        }
    }
}

@Composable
private fun GroundingScript(steps: List<String>) {
    var index by remember { mutableIntStateOf(0) }

    Column(
        Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(Spacing.large)
    ) {
        SolaceCard {
            Text(
                steps[index],
                style = MaterialTheme.typography.headlineSmall,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth().padding(vertical = Spacing.large)
            )
        }
        Text(
            "Step ${index + 1} of ${steps.size}",
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Row(horizontalArrangement = Arrangement.spacedBy(Spacing.medium)) {
            Button(onClick = { if (index > 0) index -= 1 }, enabled = index > 0) {
                Text("Back")
            }
            Button(
                onClick = { if (index < steps.lastIndex) index += 1 else index = 0 }
            ) {
                Text(if (index < steps.lastIndex) "Next" else "Start over")
            }
        }
    }
}
