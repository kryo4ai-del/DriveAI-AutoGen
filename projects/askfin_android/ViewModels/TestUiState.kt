sealed class TestUiState {
    data object Loading : TestUiState()
    data class Success(val test: TestModel) : TestUiState()
    data class Error(val message: String) : TestUiState()
}

@HiltViewModel
class TestViewModel @Inject constructor(
    private val repository: TestRepository
) : ViewModel() {
    private val _state = MutableStateFlow<TestUiState>(TestUiState.Loading)
    val state: StateFlow<TestUiState> = _state.asStateFlow()
}