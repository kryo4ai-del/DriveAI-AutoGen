package com.driveai.askfin.ui.viewmodels
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.update

interface ISkillMapService {
    suspend fun getSkillMap(): List<Category>
}

interface ResourceProvider {
    fun getString(resId: Int): String
}

data class Category(val name: String = "")

enum class SortOption { DEFAULT }
enum class FilterOption { NONE }

data class SkillMapUiState(
    val isLoading: Boolean = false,
    val categories: List<Category> = emptyList(),
    val lastRefresh: Long = 0L,
    val error: String? = null,
    val sortBy: SortOption = SortOption.DEFAULT,
    val filterBy: FilterOption = FilterOption.NONE,
)

object R {
    object string {
        val error_skill_map_load_failed: Int = 0
    }
}

@HiltViewModel
class SkillMapViewModel @Inject constructor(
    private val skillMapService: ISkillMapService,
    private val resourceProvider: ResourceProvider,
) : ViewModel() {

    companion object {
        // Remove hardcoded strings, use resourceProvider instead
    }

    private val _uiState = MutableStateFlow(SkillMapUiState())

    private fun applyFiltersAndSort(
        categories: List<Category>,
        sortBy: SortOption,
        filterBy: FilterOption,
    ): List<Category> {
        return categories
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