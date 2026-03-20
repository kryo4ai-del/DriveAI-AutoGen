package com.driveai.askfin.ui.screens

import androidx.compose.runtime.Composable
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.runtime.remember
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.foundation.layout.Column
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.runtime.collectAsState
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

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

    Column() {
        // ... header ...
        
        uiState.value.currentQuestion?.let { question ->
            Column() {
                // Answer buttons use local optimistic state
                question.answers.forEachIndexed { index: Int, answer: String ->
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

// Placeholder classes for compilation
data class ExamQuestion(val answers: List<String>)
data class ExamUiState(
    val currentQuestion: ExamQuestion?,
    val selectedAnswerIndex: Int?,
    val isAnswerCorrect: Boolean?,
    val questionNumber: Int,
    val totalQuestions: Int
)

class ExamSimulationViewModel : ViewModel() {
    val uiState: StateFlow<ExamUiState> = MutableStateFlow(ExamUiState(null, null, null, 0, 0))
    fun selectAnswer(index: Int) {}
    fun completeExam() {}
    fun nextQuestion() {}
}

@Composable
fun AnswerButton(
    text: String,
    index: Int,
    isSelected: Boolean,
    isAnswered: Boolean,
    isCorrect: Boolean?,
    onClick: () -> Unit
) {}

@Composable
fun PrimaryButton(
    text: String,
    onClick: () -> Unit
) {}