// ❌ Current: Vulnerable to double-tap
onClick = {
    if (uiState.value.selectedAnswerIndex == null) {
        viewModel.selectAnswer(index)  // Async, may be slow
    }
}

// ✅ Refactored: Optimistic local state
@Composable
fun ExamQuestionScreen(
    viewModel: ExamSimulationViewModel = hiltViewModel(),
    onExamComplete: () -> Unit
) {
    val uiState = viewModel.uiState.collectAsState()
    var localSelectedIndex by remember { mutableStateOf<Int?>(null) }
    
    // Sync local state with remote on update
    LaunchedEffect(uiState.value.selectedAnswerIndex) {
        if (uiState.value.selectedAnswerIndex != null) {
            localSelectedIndex = uiState.value.selectedAnswerIndex
        }
    }

    Column(...) {
        // ... header ...
        
        uiState.value.currentQuestion?.let { question ->
            Column(...) {
                // Answer buttons use local optimistic state
                question.answers.forEachIndexed { index, answer ->
                    AnswerButton(
                        text = answer,
                        index = index,
                        isSelected = localSelectedIndex == index,
                        isAnswered = localSelectedIndex != null,
                        isCorrect = if (localSelectedIndex == index) {
                            uiState.value.isAnswerCorrect
                        } else null,
                        onClick = {
                            // Lock immediately, don't wait for ViewModel
                            if (localSelectedIndex == null) {
                                localSelectedIndex = index
                                viewModel.selectAnswer(index)
                            }
                        }
                    )
                }
                
                if (localSelectedIndex != null) {
                    AnimatedVisibility(visible = true, enter = fadeIn()) {
                        PrimaryButton(
                            text = if (uiState.value.questionNumber == uiState.value.totalQuestions) 
                                "Prüfung beenden" else "Nächste Frage",
                            onClick = {
                                if (uiState.value.questionNumber == uiState.value.totalQuestions) {
                                    viewModel.completeExam()
                                } else {
                                    viewModel.nextQuestion()
                                    localSelectedIndex = null  // Reset for new Q
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}