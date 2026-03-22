package com.driveai.askfin.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

// ============================================================================
// PLACEHOLDER TYPES
// ============================================================================

data class Category(
    val name: String = "",
    val competencePercentage: Float = 0f,
)

interface SkillMapService {
    suspend fun getSkillMap(): List<Category>
}

// ============================================================================
// ENUMS
// ============================================================================

enum class SortOption {
    COMPETENCE_ASC,
    COMPETENCE_DESC,
    NAME_ASC,
    NAME_DESC,
}

enum class FilterOption {
    ALL,
    STRONG,
    WEAK,
}

// ============================================================================
// STATE
// ============================================================================

data class SkillMapUiState(
    val isLoading: Boolean = false,
    val categories: List<Category> = emptyList(),
    val error: String? = null,
    val sortBy: SortOption = SortOption.COMPETENCE_ASC,
    val filterBy: FilterOption = FilterOption.ALL,
    val lastRefresh: Long = 0L,
)

// ============================================================================
// VIEWMODEL
// ============================================================================

@HiltViewModel
class SkillMapViewModel @Inject constructor(
    private val skillMapService: SkillMapService,
) : ViewModel() {

    private val _uiState = MutableStateFlow(SkillMapUiState())
    val uiState: StateFlow<SkillMapUiState> = _uiState.asStateFlow()

    companion object {
        private const val COMPETENCE_THRESHOLD = 70f
        private const val ERROR_LOAD_FAILED = "Failed to load skill map"
    }

    init {
        loadSkillMap()
    }

    // ========================================================================
    // PUBLIC API
    // ========================================================================

    /**
     * Initial load of skill map data.
     */
    fun loadSkillMap() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            performFetch()
        }
    }

    /**
     * Refresh after user completes training session.
     */
    fun refreshAfterTraining() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            performFetch()
        }
    }

    /**
     * Retry after error.
     */
    fun retryLoadSkillMap() {
        loadSkillMap()
    }

    /**
     * Change sort order (applies immediately to current data).
     */
    fun setSortOption(sortOption: SortOption) {
        _uiState.update { currentState ->
            val newCategories = applyFiltersAndSort(
                currentState.categories,
                sortBy = sortOption,
                filterBy = currentState.filterBy
            )
            currentState.copy(
                sortBy = sortOption,
                categories = newCategories
            )
        }
    }

    /**
     * Change filter (applies immediately to current data).
     */
    fun setFilterOption(filterOption: FilterOption) {
        _uiState.update { currentState ->
            val newCategories = applyFiltersAndSort(
                currentState.categories,
                sortBy = currentState.sortBy,
                filterBy = filterOption
            )
            currentState.copy(
                filterBy = filterOption,
                categories = newCategories
            )
        }
    }

    /**
     * Clear error message.
     */
    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }

    // ========================================================================
    // PRIVATE HELPERS
    // ========================================================================

    /**
     * Fetch from service and update state.
     * Reusable by loadSkillMap(), refreshAfterTraining(), and retryLoadSkillMap().
     */
    private suspend fun performFetch() {
        try {
            val categories = skillMapService.getSkillMap()
            _uiState.update { currentState ->
                val sortedCategories = applyFiltersAndSort(
                    categories,
                    sortBy = currentState.sortBy,
                    filterBy = currentState.filterBy
                )
                currentState.copy(
                    isLoading = false,
                    categories = sortedCategories,
                    lastRefresh = System.currentTimeMillis(),
                    error = null,
                )
            }
        } catch (e: Exception) {
            _uiState.update {
                it.copy(
                    isLoading = false,
                    error = e.message ?: ERROR_LOAD_FAILED,
                )
            }
        }
    }

    /**
     * Apply filter and sort to categories.
     * Parameters are passed explicitly to avoid state race conditions.
     */
    private fun applyFiltersAndSort(
        categories: List<Category>,
        sortBy: SortOption,
        filterBy: FilterOption,
    ): List<Category> {
        // Apply filter
        val filtered = when (filterBy) {
            FilterOption.ALL -> categories
            FilterOption.STRONG -> categories.filter { it.competencePercentage >= COMPETENCE_THRESHOLD }
            FilterOption.WEAK -> categories.filter { it.competencePercentage < COMPETENCE_THRESHOLD }
        }

        // Apply sort
        return when (sortBy) {
            SortOption.COMPETENCE_ASC -> filtered.sortedBy { it.competencePercentage }
            SortOption.COMPETENCE_DESC -> filtered.sortedByDescending { it.competencePercentage }
            SortOption.NAME_ASC -> filtered.sortedBy { it.name }
            SortOption.NAME_DESC -> filtered.sortedByDescending { it.name }
        }
    }
}