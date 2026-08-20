package com.jonathanalumasa.solace.ui.shared

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/**
 * The Android counterpart of the iOS `AmbientBackground`. SwiftUI drives that
 * one with an animated `MeshGradient`, which Compose has no equivalent for, so
 * this layers slow-drifting radial gradients to land in the same place: a
 * gentle, colourful wash that gives each tab its own identity.
 *
 * Alpha is kept deliberately low — this sits behind body text, and a
 * mental-health app should read calm rather than loud.
 */
@Composable
fun AmbientBackground(
    colors: List<Color>,
    modifier: Modifier = Modifier.fillMaxSize()
) {
    val transition = rememberInfiniteTransition(label = "ambient")
    val phase by transition.animateFloat(
        initialValue = 0f,
        targetValue = (2 * PI).toFloat(),
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 22_000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "phase"
    )

    val base = MaterialTheme.colorScheme.background
    // Dark surfaces need less colour before text contrast suffers.
    val blobAlpha = if (isSystemInDarkTheme()) 0.28f else 0.45f

    Canvas(modifier) {
        drawRect(color = base)

        colors.forEachIndexed { index, color ->
            // Each blob gets its own phase offset and drift rate so the whole
            // field never visibly loops in lockstep.
            val seed = index * 1.7f
            val centre = Offset(
                x = size.width * (0.5f + 0.40f * sin(phase + seed)),
                y = size.height * (0.45f + 0.36f * cos(phase * 0.75f + seed * 1.3f))
            )
            val radius = size.minDimension * 0.80f

            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(color.copy(alpha = blobAlpha), Color.Transparent),
                    center = centre,
                    radius = radius
                ),
                radius = radius,
                center = centre
            )
        }
    }
}
