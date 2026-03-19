@HiltViewModel
class SkillMapViewModel @Inject constructor(
    private val skillMapService: SkillMapService,
    private val resourceProvider: ResourceProvider,  // Custom abstraction
) : ViewModel() {
    
    companion object {
        // Remove hardcoded strings, use resourceProvider instead
    }

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
            val errorMessage = resourceProvider.getString(
                R.string.error_skill_map_load_failed
            )
            _uiState.update {
                it.copy(
                    isLoading = false,
                    error = errorMessage,
                )
            }
        }
    }
}