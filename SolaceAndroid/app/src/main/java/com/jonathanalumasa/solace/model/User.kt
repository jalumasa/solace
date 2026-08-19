package com.jonathanalumasa.solace.model

import java.util.Date

/**
 * Mirrors `SolaceCore.Role`. Raw values must stay identical to the iOS app's —
 * they're persisted in Firestore and compared directly in firestore.rules.
 */
enum class Role(val rawValue: String) {
    STUDENT("student"),
    COUNSELOR("counselor");

    companion object {
        fun fromRaw(raw: String?): Role? = entries.firstOrNull { it.rawValue == raw }
    }
}

/** Mirrors `SolaceCore.AcademicYear`. */
enum class AcademicYear(val rawValue: String, val label: String) {
    FRESHMAN("freshman", "Freshman"),
    SOPHOMORE("sophomore", "Sophomore"),
    JUNIOR("junior", "Junior"),
    SENIOR("senior", "Senior"),
    GRADUATE("graduate", "Graduate");

    companion object {
        fun fromRaw(raw: String?): AcademicYear? = entries.firstOrNull { it.rawValue == raw }
    }
}

/** Mirrors `SolaceCore.User`. */
data class User(
    val id: String,
    val email: String,
    val displayName: String,
    val role: Role,
    val bio: String? = null,
    /** Student-only academic details. Always null for counselors. */
    val major: String? = null,
    val academicYear: AcademicYear? = null,
    val age: Int? = null,
    val createdAt: Date = Date()
)
