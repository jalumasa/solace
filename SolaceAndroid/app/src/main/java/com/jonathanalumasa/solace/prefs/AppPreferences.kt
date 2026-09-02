package com.jonathanalumasa.solace.prefs

import android.content.Context
import android.content.SharedPreferences

/**
 * The Android counterpart of the iOS app's `@AppStorage` values — the small
 * per-device settings that never belong in Firestore because they're about
 * this install, not this account.
 */
class AppPreferences(context: Context) {
    private val prefs: SharedPreferences =
        context.applicationContext.getSharedPreferences("solace", Context.MODE_PRIVATE)

    var hasCompletedOnboarding: Boolean
        get() = prefs.getBoolean(KEY_ONBOARDING, false)
        set(value) = prefs.edit().putBoolean(KEY_ONBOARDING, value).apply()

    var reminderEnabled: Boolean
        get() = prefs.getBoolean(KEY_REMINDER_ENABLED, false)
        set(value) = prefs.edit().putBoolean(KEY_REMINDER_ENABLED, value).apply()

    /** Minutes since midnight; defaults to 19:00, matching iOS. */
    var reminderMinutes: Int
        get() = prefs.getInt(KEY_REMINDER_MINUTES, 19 * 60)
        set(value) = prefs.edit().putInt(KEY_REMINDER_MINUTES, value).apply()

    private companion object {
        const val KEY_ONBOARDING = "hasCompletedOnboarding"
        const val KEY_REMINDER_ENABLED = "reminderEnabled"
        const val KEY_REMINDER_MINUTES = "reminderMinutesSinceMidnight"
    }
}
