package com.jonathanalumasa.solace.model

/** Mirrors `SolaceCore.ResourceCategory`. */
enum class ResourceCategory(val rawValue: String, val displayName: String) {
    ANXIETY("anxiety", "Anxiety"),
    STRESS("stress", "Stress"),
    SLEEP("sleep", "Sleep"),
    DEPRESSION("depression", "Depression"),
    GENERAL("general", "General Wellbeing");

    companion object {
        fun fromRaw(raw: String?): ResourceCategory? = entries.firstOrNull { it.rawValue == raw }
    }
}

/** Mirrors `SolaceCore.ResourceItem`. */
data class ResourceItem(
    val id: String,
    val title: String,
    val summary: String,
    val body: String,
    val category: ResourceCategory,
    val tags: List<String> = emptyList()
)

/** Mirrors `SolaceCore.BreathingPattern`, in seconds. */
data class BreathingPattern(
    val inhale: Int,
    val hold: Int,
    val exhale: Int,
    val holdAfterExhale: Int
) {
    companion object {
        val FOUR_SEVEN_EIGHT = BreathingPattern(4, 7, 8, 0)
        val BOX = BreathingPattern(4, 4, 4, 4)
    }
}

/** Mirrors `SolaceCore.RelaxationKind`. */
sealed interface RelaxationKind {
    data class Breathing(val pattern: BreathingPattern) : RelaxationKind
    data class GroundingScript(val steps: List<String>) : RelaxationKind
}

/**
 * Mirrors `SolaceCore.RelaxationExercise`. Static in-code content — not
 * persisted, so it stays available with no network.
 */
data class RelaxationExercise(
    val id: String,
    val title: String,
    val description: String,
    val kind: RelaxationKind
) {
    companion object {
        val breathingExercises = listOf(
            RelaxationExercise(
                id = "box-breathing",
                title = "Box Breathing",
                description = "A steady four-count pattern used to calm the nervous system quickly.",
                kind = RelaxationKind.Breathing(BreathingPattern.BOX)
            ),
            RelaxationExercise(
                id = "four-seven-eight",
                title = "4-7-8 Breathing",
                description = "A longer exhale pattern that promotes deep relaxation before sleep.",
                kind = RelaxationKind.Breathing(BreathingPattern.FOUR_SEVEN_EIGHT)
            )
        )

        val groundingExercises = listOf(
            RelaxationExercise(
                id = "five-four-three-two-one",
                title = "5-4-3-2-1 Grounding",
                description = "A sensory grounding technique for moments of acute anxiety.",
                kind = RelaxationKind.GroundingScript(
                    listOf(
                        "Name 5 things you can see around you.",
                        "Name 4 things you can touch or feel.",
                        "Name 3 things you can hear.",
                        "Name 2 things you can smell.",
                        "Name 1 thing you can taste."
                    )
                )
            ),
            RelaxationExercise(
                id = "body-scan",
                title = "Body Scan",
                description = "A slow pass through the body to notice and release tension.",
                kind = RelaxationKind.GroundingScript(
                    listOf(
                        "Notice your feet touching the ground.",
                        "Relax your shoulders away from your ears.",
                        "Unclench your jaw and let your tongue rest.",
                        "Soften your hands, even if they're empty.",
                        "Take one more full breath before you go."
                    )
                )
            ),
            RelaxationExercise(
                id = "three-good-things",
                title = "Three Good Things",
                description = "A short gratitude reflection to close out a hard day.",
                kind = RelaxationKind.GroundingScript(
                    listOf(
                        "Think of one small thing that went well today.",
                        "Notice how that feels in your body right now.",
                        "Think of one person you're grateful for.",
                        "Think of one thing your body did for you today.",
                        "Carry just one of these with you as you go."
                    )
                )
            )
        )

        val all = breathingExercises + groundingExercises
    }
}

/** Mirrors `SolaceCore.CrisisContact`. */
data class CrisisContact(val id: String, val name: String, val detail: String)

/**
 * Static, always-available crisis resources. The AI companion is for general
 * support only and is not equipped for active crises, so these must stay
 * visible and must never depend on a network call.
 */
object CrisisSupport {
    val contacts = listOf(
        CrisisContact(
            id = "988",
            name = "988 Suicide & Crisis Lifeline",
            detail = "Call or text 988 (US) — available 24/7"
        ),
        CrisisContact(
            id = "crisis-text-line",
            name = "Crisis Text Line",
            detail = "Text HOME to 741741 (US) — available 24/7"
        )
    )
}
