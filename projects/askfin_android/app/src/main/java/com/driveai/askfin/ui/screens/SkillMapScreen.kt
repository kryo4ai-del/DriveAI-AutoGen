package com.driveai.askfin.ui.screens
import androidx.compose.runtime.Composable
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.foundation.layout.Row
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import javax.inject.Inject

data class SkillMapUiState(
    val isLoading: Boolean = false,
    val error: String? = null,
    val sortBy: String = "",
    val filterBy: String = "",
    val categories: List<Any> = emptyList()
)

@HiltViewModel
class SkillMapViewModel @Inject constructor() : ViewModel() {
    val uiState: StateFlow<SkillMapUiState> = MutableStateFlow(SkillMapUiState())

    fun retryLoadSkillMap() {}
    fun setSortOption(option: String) {}
    fun setFilterOption(option: String) {}
}

@Composable
fun LoadingIndicator() {}

@Composable
fun ErrorBanner(error: String?) {}

@Composable
fun SortDropdown(selected: String, onSelect: (String) -> Unit) {}

@Composable
fun FilterDropdown(selected: String, onSelect: (String) -> Unit) {}

@Composable
fun SkillMapList(categories: List<Any>) {}

@Composable
fun SkillMapScreen(
    viewModel: SkillMapViewModel = hiltViewModel(),
) {
    val state by viewModel.uiState.collectAsState()

    when {
        state.isLoading -> LoadingIndicator()
        state.error != null -> {
            ErrorBanner(state.error)
            Button(onClick = { viewModel.retryLoadSkillMap() }) {
                Text("Retry")
            }
        }
        else -> {
            Row {
                SortDropdown(
                    selected = state.sortBy,
                    onSelect = { viewModel.setSortOption(it) }
                )
                FilterDropdown(
                    selected = state.filterBy,
                    onSelect = { viewModel.setFilterOption(it) }
                )
            }
            SkillMapList(categories = state.categories)
        }
    }
}