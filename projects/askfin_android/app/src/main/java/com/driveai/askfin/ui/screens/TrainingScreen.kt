package com.driveai.askfin.ui.screens

@Composable
fun TrainingScreen(viewModel: TrainingViewModel) {
    val focusRequester = remember { FocusRequester() }
    
    LaunchedEffect(viewModel.uiState.collectAsState().value.currentIndex) {
        // Move focus to new question when it loads
        focusRequester.requestFocus()
        announceForAccessibility("Next question loaded. Focus moved to question.")
    }
    
    QuestionCard(
        question = ...,
        modifier = Modifier.focusRequester(focusRequester)
    )
}