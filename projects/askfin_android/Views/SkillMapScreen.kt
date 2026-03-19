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