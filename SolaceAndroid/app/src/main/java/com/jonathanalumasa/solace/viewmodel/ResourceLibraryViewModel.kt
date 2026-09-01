package com.jonathanalumasa.solace.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.jonathanalumasa.solace.model.ResourceCategory
import com.jonathanalumasa.solace.model.ResourceItem
import com.jonathanalumasa.solace.service.ResourceService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * Mirrors `SolaceCore.ResourceLibraryViewModel`. Relaxation exercises are
 * static in-code content on both clients, so only the articles come from
 * Firestore here.
 */
class ResourceLibraryViewModel(
    private val resourceService: ResourceService
) : ViewModel() {

    private val _resources = MutableStateFlow<List<ResourceItem>>(emptyList())
    val resources: StateFlow<List<ResourceItem>> = _resources.asStateFlow()

    private val _selectedCategory = MutableStateFlow<ResourceCategory?>(null)
    val selectedCategory: StateFlow<ResourceCategory?> = _selectedCategory.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        load()
    }

    fun load() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                _resources.value = resourceService.fetchResources()
            } catch (error: Exception) {
                _errorMessage.value = "Couldn't load articles. Please try again."
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun selectCategory(category: ResourceCategory?) {
        _selectedCategory.value = category
    }

    fun filtered(all: List<ResourceItem>, category: ResourceCategory?): List<ResourceItem> =
        if (category == null) all else all.filter { it.category == category }
}
