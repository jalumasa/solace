package com.jonathanalumasa.solace.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jonathanalumasa.solace.model.GardenStage
import com.jonathanalumasa.solace.model.GratitudeEntry
import com.jonathanalumasa.solace.service.JournalService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/** Mirrors `SolaceCore.GratitudeGardenViewModel`. */
class GratitudeGardenViewModel(
    private val currentUserID: String,
    private val journalService: JournalService
) : ViewModel() {

    private val _entries = MutableStateFlow<List<GratitudeEntry>>(emptyList())
    val entries: StateFlow<List<GratitudeEntry>> = _entries.asStateFlow()

    private val _draftText = MutableStateFlow("")
    val draftText: StateFlow<String> = _draftText.asStateFlow()

    private val _isSaving = MutableStateFlow(false)
    val isSaving: StateFlow<Boolean> = _isSaving.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        viewModelScope.launch {
            journalService.observeGratitudeEntries(currentUserID).collect { _entries.value = it }
        }
    }

    val stage: GardenStage get() = GardenStage.forEntryCount(_entries.value.size)

    fun updateDraft(value: String) {
        _draftText.value = value
    }

    fun addEntry() {
        val text = _draftText.value.trim()
        if (text.isEmpty() || _isSaving.value) return
        viewModelScope.launch {
            _errorMessage.value = null
            _isSaving.value = true
            try {
                journalService.addGratitudeEntry(text, currentUserID)
                _draftText.value = ""
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't save that entry. Please try again."
            } finally {
                _isSaving.value = false
            }
        }
    }
}
