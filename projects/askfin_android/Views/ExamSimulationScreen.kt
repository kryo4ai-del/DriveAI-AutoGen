@Composable
fun ExamSimulationScreen(
    viewModel: ExamSimulationViewModel = hiltViewModel()
) {
    val hapticFeedback: HapticFeedback = remember {
        // Manual injection via LocalContext
        val context = LocalContext.current
        HapticFeedback(context)
    }
    // ...
}