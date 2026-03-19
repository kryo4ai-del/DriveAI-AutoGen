@HiltViewModel
class ReadinessScoreViewModel @Inject constructor(
    private val readinessRepository: ReadinessRepository
) : ViewModel() {
    // No retry logic, no error recovery