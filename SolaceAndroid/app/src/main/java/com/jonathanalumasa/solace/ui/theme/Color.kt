package com.jonathanalumasa.solace.ui.theme

import androidx.compose.ui.graphics.Color
import com.jonathanalumasa.solace.model.MoodLevel

/**
 * The Solace accent palette, carried across from the iOS app's `Theme.swift`
 * so both clients read as the same product. Liquid Glass is iOS-only, so the
 * Android app expresses the same identity through Material 3 surfaces rather
 * than trying to imitate glass.
 */
object SolaceColors {
    /** Primary brand accent — carried over from the original leaf mark. */
    val Primary = Color(0xFF00A0A0)

    /** Secondary calming tone used on reflective surfaces (Today, Games). */
    val Secondary = Color(0xFF9E94F0)

    /** Warm tone reserved for streaks/encouragement, never for errors. */
    val Warm = Color(0xFFFAB56B)

    /** Rotating accent palette for iconography — quick actions, game rows. */
    val Coral = Color(0xFFFA736B)
    val Sky = Color(0xFF59ADFA)
    val Leaf = Color(0xFF66C78C)
    val Sun = Color(0xFFFAC23D)
}

/** Mirrors the iOS `MoodLevel.color` extension. */
val MoodLevel.color: Color
    get() = when (this) {
        MoodLevel.AWFUL -> SolaceColors.Coral
        MoodLevel.BAD -> SolaceColors.Warm
        MoodLevel.OKAY -> SolaceColors.Sun
        MoodLevel.GOOD -> SolaceColors.Leaf
        MoodLevel.GREAT -> SolaceColors.Primary
    }
