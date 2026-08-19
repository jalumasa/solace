package com.jonathanalumasa.solace.model

import java.util.Date

/**
 * Mirrors `SolaceCore.MoodLevel`. Stored in Firestore as the raw Int, which
 * firestore.rules range-checks (1...5) on create.
 */
enum class MoodLevel(val rawValue: Int, val label: String, val emoji: String) {
    AWFUL(1, "Awful", "😞"),
    BAD(2, "Bad", "🙁"),
    OKAY(3, "Okay", "😐"),
    GOOD(4, "Good", "🙂"),
    GREAT(5, "Great", "😄");

    companion object {
        fun fromRaw(raw: Int?): MoodLevel? = entries.firstOrNull { it.rawValue == raw }
    }
}

/** Mirrors `SolaceCore.MoodEntry`. */
data class MoodEntry(
    val id: String,
    val mood: MoodLevel,
    val note: String? = null,
    val createdAt: Date = Date()
)
