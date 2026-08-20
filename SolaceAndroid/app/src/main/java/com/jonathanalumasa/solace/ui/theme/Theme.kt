package com.jonathanalumasa.solace.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp

/** Spacing scale mirroring iOS `Theme.Spacing`. */
object Spacing {
    val xSmall = 4.dp
    val small = 8.dp
    val medium = 16.dp
    val large = 24.dp
    val xLarge = 32.dp
}

/** Corner radii mirroring iOS `Theme.Radius`. */
object Radius {
    val card = 24.dp
    val control = 16.dp
}

private val LightColors = lightColorScheme(
    primary = SolaceColors.Primary,
    secondary = SolaceColors.Secondary,
    tertiary = SolaceColors.Sky,
    error = SolaceColors.Coral
)

private val DarkColors = darkColorScheme(
    primary = SolaceColors.Primary,
    secondary = SolaceColors.Secondary,
    tertiary = SolaceColors.Sky,
    error = SolaceColors.Coral
)

/**
 * @param dynamicColor opts into Material You wallpaper-derived color on
 *   Android 12+. Defaults to off so the Solace palette stays recognisable
 *   across devices, matching the iOS app's fixed identity.
 */
@Composable
fun SolaceTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }

        darkTheme -> DarkColors
        else -> LightColors
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}

/**
 * Per-tab ambient gradient palettes, mirroring iOS `Theme.Ambient` — each tab
 * gets its own gentle identity rather than one flat background. iOS renders
 * these as an animated mesh gradient; see `AmbientBackground` for how Compose
 * approximates that with drifting radial gradients.
 */
object Ambient {
    val today: List<Color> = listOf(
        SolaceColors.Sun, SolaceColors.Coral, SolaceColors.Warm, SolaceColors.Secondary
    )
    val talk: List<Color> = listOf(
        SolaceColors.Sky, SolaceColors.Primary, SolaceColors.Secondary, SolaceColors.Sky
    )
    val wellness: List<Color> = listOf(
        SolaceColors.Leaf, SolaceColors.Primary, SolaceColors.Sky, SolaceColors.Leaf
    )
    val games: List<Color> = listOf(
        SolaceColors.Secondary, SolaceColors.Coral, SolaceColors.Sun, SolaceColors.Leaf
    )
    val profile: List<Color> = listOf(
        SolaceColors.Primary, SolaceColors.Secondary, SolaceColors.Sky, SolaceColors.Leaf
    )
}
