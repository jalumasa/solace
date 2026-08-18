package com.jonathanalumasa.solace.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jonathanalumasa.solace.model.GratitudeEntry
import com.jonathanalumasa.solace.model.MoodEntry
import com.jonathanalumasa.solace.model.MoodLevel
import com.jonathanalumasa.solace.model.User
import com.jonathanalumasa.solace.service.JournalService
import com.jonathanalumasa.solace.service.MoodService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.Calendar
import java.util.Date

/** Mirrors `SolaceCore.TodayViewModel`. */
class TodayViewModel(
    val currentUser: User,
    private val moodService: MoodService,
    private val journalService: JournalService
) : ViewModel() {

    private val _moodHistory = MutableStateFlow<List<MoodEntry>>(emptyList())
    val moodHistory: StateFlow<List<MoodEntry>> = _moodHistory.asStateFlow()

    private val _gratitudeEntries = MutableStateFlow<List<GratitudeEntry>>(emptyList())
    val gratitudeEntries: StateFlow<List<GratitudeEntry>> = _gratitudeEntries.asStateFlow()

    private val _isSubmittingMood = MutableStateFlow(false)
    val isSubmittingMood: StateFlow<Boolean> = _isSubmittingMood.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        viewModelScope.launch {
            moodService.observeMoodHistory(currentUser.id).collect { _moodHistory.value = it }
        }
        viewModelScope.launch {
            journalService.observeGratitudeEntries(currentUser.id).collect {
                _gratitudeEntries.value = it
            }
        }
    }

    fun clearError() {
        _errorMessage.value = null
    }

    val greeting: String
        get() {
            val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
            val timeOfDay = when (hour) {
                in 0..11 -> "morning"
                in 12..16 -> "afternoon"
                else -> "evening"
            }
            return "Good $timeOfDay, ${currentUser.displayName}"
        }

    val hasCheckedInToday: Boolean
        get() {
            val mostRecent = _moodHistory.value.firstOrNull() ?: return false
            return isSameDay(mostRecent.createdAt, Date())
        }

    /**
     * Consecutive calendar days (ending today or yesterday — a missed today
     * doesn't zero out yesterday's progress until tomorrow) with at least one
     * mood check-in or journal entry.
     */
    val streak: Int
        get() {
            val days = buildSet {
                _moodHistory.value.forEach { add(startOfDay(it.createdAt)) }
                _gratitudeEntries.value.forEach { add(startOfDay(it.createdAt)) }
            }
            if (days.isEmpty()) return 0

            var cursor = startOfDay(Date())
            if (!days.contains(cursor)) {
                val yesterday = addDays(cursor, -1)
                if (!days.contains(yesterday)) return 0
                cursor = yesterday
            }

            var count = 0
            while (days.contains(cursor)) {
                count += 1
                cursor = addDays(cursor, -1)
            }
            return count
        }

    fun logMood(mood: MoodLevel, note: String? = null) {
        viewModelScope.launch {
            _errorMessage.value = null
            _isSubmittingMood.value = true
            try {
                moodService.logMood(mood, note, currentUser.id)
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't save your check-in. Please try again."
            } finally {
                _isSubmittingMood.value = false
            }
        }
    }

    private fun startOfDay(date: Date): Long = Calendar.getInstance().apply {
        time = date
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    private fun addDays(startOfDayMillis: Long, days: Int): Long =
        Calendar.getInstance().apply {
            timeInMillis = startOfDayMillis
            add(Calendar.DAY_OF_YEAR, days)
        }.timeInMillis

    private fun isSameDay(a: Date, b: Date): Boolean = startOfDay(a) == startOfDay(b)
}
