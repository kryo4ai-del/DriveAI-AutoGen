package com.driveai.askfin.ui.screens

import androidx.compose.foundation.focusable
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.remember
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

data class TrainingUiState(val currentIndex: Int = 0)

data class Question(val text: String = "")

class TrainingViewModel : ViewModel() {
    val uiState: StateFlow<TrainingUiState> = MutableStateFlow(TrainingUiState())
    val currentQuestion: Question = Question()
}

@Composable
fun QuestionCard(question: Question, modifier: Modifier = Modifier) {
    // Placeholder implementation
}

@Composable
fun TrainingScreen(viewModel: TrainingViewModel) {
    val focusRequester = remember { FocusRequester() }

    LaunchedEffect(viewModel.uiState.collectAsState().value.currentIndex) {
        // Move focus to new question when it loads
        focusRequester.requestFocus()
        // announceForAccessibility is not available in Compose directly; placeholder comment
        // announceForAccessibility("Next question loaded. Focus moved to question.")
    }

    QuestionCard(
        question = viewModel.currentQuestion,
        modifier = Modifier.focusRequester(focusRequester)
    )
}