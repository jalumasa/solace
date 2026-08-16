package com.jonathanalumasa.solace.model

import java.util.Date

/** Mirrors `SolaceCore.GratitudeEntry`. */
data class GratitudeEntry(
    val id: String,
    val text: String,
    val createdAt: Date = Date()
)

/**
 * Mirrors `SolaceCore.GardenStage` — growth derived purely from entry count,
 * no scoring, just gentle visual progress.
 */
enum class GardenStage(val label: String, val description: String) {
    SEED("Seed", "Plant your first gratitude to get started."),
    SPROUT("Sprout", "Your garden is sprouting. Keep it going."),
    BLOOM("Bloom", "Your garden is blooming beautifully."),
    FLOURISHING("Flourishing Garden", "A flourishing garden — look how far you've come.");

    companion object {
        fun forEntryCount(count: Int): GardenStage = when (count) {
            in 0..2 -> SEED
            in 3..6 -> SPROUT
            in 7..14 -> BLOOM
            else -> FLOURISHING
        }
    }
}
