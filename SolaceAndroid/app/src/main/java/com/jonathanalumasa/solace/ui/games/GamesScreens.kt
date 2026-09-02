package com.jonathanalumasa.solace.ui.games

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Air
import androidx.compose.material.icons.filled.BubbleChart
import androidx.compose.material.icons.filled.Landscape
import androidx.compose.material.icons.filled.LocalFlorist
import androidx.compose.material.icons.filled.RadioButtonUnchecked
import androidx.compose.material3.Button
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.jonathanalumasa.solace.model.GardenStage
import com.jonathanalumasa.solace.ui.shared.IconRow
import com.jonathanalumasa.solace.ui.shared.ScreenTitle
import com.jonathanalumasa.solace.ui.shared.SolaceCard
import com.jonathanalumasa.solace.ui.theme.SolaceColors
import com.jonathanalumasa.solace.ui.theme.Spacing
import com.jonathanalumasa.solace.viewmodel.GratitudeGardenViewModel
import kotlinx.coroutines.delay

enum class SolaceGame(val title: String, val subtitle: String) {
    BUBBLE_POP("Bubble Pop", "Pop a grid of bubbles for quick stress relief"),
    GRATITUDE_GARDEN("Gratitude Garden", "Grow a garden by noting what you're grateful for"),
    FOCUS_RINGS("Focus Rings", "A gentle tap-when-ready attention exercise"),
    ZEN_GARDEN("Zen Garden", "Rake calming patterns into sand — nothing to get wrong"),
    WORRY_JAR("Worry Jar", "Write down a worry, then let it go")
}

@Composable
fun GamesScreen(onOpenGame: (SolaceGame) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(Spacing.large)) {
        ScreenTitle("Games")
        Text(
            "A few calm, no-pressure activities — no scores, no losing.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        SolaceCard {
            SolaceGame.entries.forEachIndexed { index, game ->
                Box(Modifier.clickable { onOpenGame(game) }) {
                    IconRow(
                        title = game.title,
                        subtitle = game.subtitle,
                        icon = when (game) {
                            SolaceGame.BUBBLE_POP -> Icons.Filled.BubbleChart
                            SolaceGame.GRATITUDE_GARDEN -> Icons.Filled.LocalFlorist
                            SolaceGame.FOCUS_RINGS -> Icons.Filled.RadioButtonUnchecked
                            SolaceGame.ZEN_GARDEN -> Icons.Filled.Landscape
                            SolaceGame.WORRY_JAR -> Icons.Filled.Air
                        },
                        tint = when (game) {
                            SolaceGame.BUBBLE_POP -> SolaceColors.Sky
                            SolaceGame.GRATITUDE_GARDEN -> SolaceColors.Leaf
                            SolaceGame.FOCUS_RINGS -> SolaceColors.Secondary
                            SolaceGame.ZEN_GARDEN -> SolaceColors.Sun
                            SolaceGame.WORRY_JAR -> SolaceColors.Coral
                        }
                    )
                }
                if (index != SolaceGame.entries.lastIndex) HorizontalDivider()
            }
        }
    }
}

@Composable
fun GameScreen(game: SolaceGame, gratitudeViewModel: GratitudeGardenViewModel) {
    Column(verticalArrangement = Arrangement.spacedBy(Spacing.large)) {
        ScreenTitle(game.title)
        when (game) {
            SolaceGame.BUBBLE_POP -> BubblePop()
            SolaceGame.GRATITUDE_GARDEN -> GratitudeGarden(gratitudeViewModel)
            SolaceGame.FOCUS_RINGS -> FocusRings()
            SolaceGame.ZEN_GARDEN -> ZenGarden()
            SolaceGame.WORRY_JAR -> WorryJar()
        }
    }
}

@Composable
private fun BubblePop() {
    val total = 24
    val popped = remember { mutableStateListOf<Int>() }

    Text(
        "Tap each bubble. When they're all popped, start again.",
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )

    LazyVerticalGrid(
        columns = GridCells.Fixed(4),
        verticalArrangement = Arrangement.spacedBy(Spacing.small),
        horizontalArrangement = Arrangement.spacedBy(Spacing.small),
        modifier = Modifier.height(360.dp)
    ) {
        items((0 until total).toList()) { index ->
            val isPopped = popped.contains(index)
            val scale by animateFloatAsState(if (isPopped) 0.4f else 1f, label = "pop")
            Box(
                Modifier
                    .aspectRatio(1f)
                    .background(
                        if (isPopped) SolaceColors.Sky.copy(alpha = 0.12f)
                        else SolaceColors.Sky.copy(alpha = 0.55f * scale + 0.15f),
                        CircleShape
                    )
                    .clickable(enabled = !isPopped) { popped.add(index) }
            )
        }
    }

    if (popped.size == total) {
        Button(onClick = { popped.clear() }, modifier = Modifier.fillMaxWidth()) {
            Text("All popped — go again")
        }
    } else {
        Text(
            "${total - popped.size} left",
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun GratitudeGarden(viewModel: GratitudeGardenViewModel) {
    val entries by viewModel.entries.collectAsStateWithLifecycle()
    val draft by viewModel.draftText.collectAsStateWithLifecycle()
    val isSaving by viewModel.isSaving.collectAsStateWithLifecycle()
    val error by viewModel.errorMessage.collectAsStateWithLifecycle()
    val stage = viewModel.stage

    Text(
        stage.description,
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )

    SolaceCard {
        Column(
            Modifier.fillMaxWidth().padding(vertical = Spacing.large),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                when (stage) {
                    GardenStage.SEED -> "🌱"
                    GardenStage.SPROUT -> "🌿"
                    GardenStage.BLOOM -> "🌷"
                    GardenStage.FLOURISHING -> "🌻"
                },
                style = MaterialTheme.typography.displayLarge
            )
            Text(stage.label, style = MaterialTheme.typography.titleMedium)
            Text(
                "${entries.size} ${if (entries.size == 1) "entry" else "entries"}",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }

    OutlinedTextField(
        value = draft,
        onValueChange = viewModel::updateDraft,
        placeholder = { Text("Something you're grateful for…") },
        enabled = !isSaving,
        modifier = Modifier.fillMaxWidth(),
        maxLines = 3
    )

    error?.let {
        Text(it, color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
    }

    Button(
        onClick = viewModel::addEntry,
        enabled = draft.isNotBlank() && !isSaving,
        modifier = Modifier.fillMaxWidth()
    ) {
        Text(if (isSaving) "Planting…" else "Plant it")
    }

    if (entries.isNotEmpty()) {
        Text("Recent gratitude", style = MaterialTheme.typography.titleSmall)
        SolaceCard {
            entries.take(5).forEach { entry ->
                Text(entry.text, modifier = Modifier.padding(vertical = Spacing.xSmall))
            }
        }
    }
}

@Composable
private fun FocusRings() {
    var isReady by remember { mutableStateOf(false) }
    var calmStreak by remember { mutableIntStateOf(0) }
    var progress by remember { mutableStateOf(0f) }

    LaunchedEffect(isReady) {
        if (!isReady) {
            progress = 0f
            repeat(100) {
                delay(30)
                progress = (it + 1) / 100f
            }
            isReady = true
        }
    }

    Text(
        "Wait for the ring to fill, then tap. Missing it costs nothing.",
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )

    Box(
        Modifier
            .fillMaxWidth()
            .height(280.dp)
            .clickable {
                if (isReady) {
                    calmStreak += 1
                    isReady = false
                }
            },
        contentAlignment = Alignment.Center
    ) {
        androidx.compose.foundation.Canvas(Modifier.fillMaxSize()) {
            val radius = size.minDimension / 3f
            drawCircle(
                color = SolaceColors.Secondary.copy(alpha = 0.15f),
                radius = radius
            )
            drawCircle(
                color = if (isReady) SolaceColors.Leaf else SolaceColors.Secondary,
                radius = radius * (0.3f + 0.7f * progress),
                style = androidx.compose.ui.graphics.drawscope.Stroke(width = 8f)
            )
        }
        Text(
            if (isReady) "Tap now" else "Breathe…",
            style = MaterialTheme.typography.titleLarge
        )
    }

    Text(
        "$calmStreak calm taps",
        style = MaterialTheme.typography.labelMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )
}

@Composable
private fun ZenGarden() {
    val strokes = remember { mutableStateListOf<List<Offset>>() }
    val current = remember { mutableStateListOf<Offset>() }

    Text(
        "Drag your finger to rake the sand. There's no pattern to get right.",
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )

    Box(
        Modifier
            .fillMaxWidth()
            .height(380.dp)
            .background(Color(0xFFEDD9AE), RoundedCornerShape(Spacing.large))
            .pointerInput(Unit) {
                detectDragGestures(
                    onDragStart = { current.clear() },
                    onDragEnd = {
                        if (current.size > 1) strokes.add(current.toList())
                        current.clear()
                    }
                ) { change, _ ->
                    current.add(change.position)
                }
            }
    ) {
        androidx.compose.foundation.Canvas(Modifier.fillMaxSize()) {
            val rake = Color(0xFF9E8558)
            (strokes + listOf(current.toList())).forEach { stroke ->
                // Five offset lines make one drag read as a rake, not a pen.
                for (line in -2..2) {
                    stroke.zipWithNext { a, b ->
                        drawLine(
                            color = rake.copy(alpha = 0.5f),
                            start = Offset(a.x, a.y + line * 4f),
                            end = Offset(b.x, b.y + line * 4f),
                            strokeWidth = 2f
                        )
                    }
                }
            }
        }
    }

    Button(onClick = { strokes.clear(); current.clear() }) { Text("Clear") }
}

@Composable
private fun WorryJar() {
    var draft by remember { mutableStateOf("") }
    var released by remember { mutableIntStateOf(0) }
    var releasing by remember { mutableStateOf(false) }

    val alpha by animateFloatAsState(
        targetValue = if (releasing) 0f else 1f,
        animationSpec = tween(900),
        label = "release"
    )

    LaunchedEffect(releasing) {
        if (releasing) {
            delay(950)
            draft = ""
            released += 1
            releasing = false
        }
    }

    Text(
        "Write down what's weighing on you, then let it go.",
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )

    SolaceCard {
        Box(
            Modifier.fillMaxWidth().height(160.dp),
            contentAlignment = Alignment.Center
        ) {
            if (draft.isBlank()) {
                Text("🍃", style = MaterialTheme.typography.displayMedium)
            } else {
                Text(
                    draft,
                    style = MaterialTheme.typography.bodyLarge,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(Spacing.medium).let {
                        it
                    },
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = alpha)
                )
            }
        }
    }

    OutlinedTextField(
        value = draft,
        onValueChange = { draft = it },
        placeholder = { Text("I'm worried about…") },
        enabled = !releasing,
        modifier = Modifier.fillMaxWidth(),
        maxLines = 4
    )

    Button(
        onClick = { releasing = true },
        enabled = draft.isNotBlank() && !releasing,
        modifier = Modifier.fillMaxWidth()
    ) {
        Text("Let it go")
    }

    Text(
        "$released worr${if (released == 1) "y" else "ies"} released this session",
        style = MaterialTheme.typography.labelMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )
}
