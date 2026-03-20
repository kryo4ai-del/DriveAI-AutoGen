package com.driveai.askfin.ui.screens
import androidx.compose.runtime.Composable
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.foundation.layout.Column
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.material3.Button
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.material3.Text
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.foundation.layout.Box
import androidx.compose.ui.Alignment
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Card
import androidx.compose.foundation.layout.wrapContentHeight

// Placeholder data classes and sealed classes

data class Answer(
    val id: String,
    val text: String,
    val isCorrect: Boolean,
)

data class Question(
    val id: String,
    val text: String,
    val answers: List<Answer>,
)

sealed class TrainingModeUiState {
    object Loading : TrainingModeUiState()
    data class Ready(
        val questions: List<Question>,
        val currentIndex: Int,
        val progress: Float,
    ) : TrainingModeUiState()
    data class Error(val message: String) : TrainingModeUiState()
    data class Complete(val score: Int, val totalQuestions: Int) : TrainingModeUiState()
}

class TrainingModeViewModel : ViewModel() {
    val uiState: StateFlow<TrainingModeUiState> = MutableStateFlow(TrainingModeUiState.Loading)
    val selectedAnswerId: StateFlow<String?> = MutableStateFlow(null)
    val isAnswerRevealed: StateFlow<Boolean> = MutableStateFlow(false)

    fun selectAnswer(answerId: String) {}
    fun revealAnswer() {}
    fun nextQuestion() {}
    fun retry() {}
}

@Composable
fun LoadingIndicator() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        CircularProgressIndicator()
    }
}

@Composable
fun TrainingModeProgressBar(
    currentQuestion: Int,
    totalQuestions: Int,
    progress: Float,
) {
    Column {
        Text("Question $currentQuestion of $totalQuestions")
        LinearProgressIndicator(
            progress = progress,
            modifier = Modifier.fillMaxWidth(),
        )
    }
}

@Composable
fun QuestionCard(
    question: Question,
    isSelected: Boolean,
    isAnswerRevealed: Boolean,
    onAnswerSelect: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    Card(modifier = modifier.wrapContentHeight()) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(question.text)
            question.answers.forEach { answer ->
                Button(onClick = { onAnswerSelect(answer.id) }) {
                    Text(answer.text)
                }
            }
        }
    }
}

@Composable
fun ErrorState(
    message: String,
    onRetry: () -> Unit,
) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(message)
        Button(onClick = onRetry) {
            Text("Retry")
        }
    }
}

@Composable
fun CompletionState(
    score: Int,
    totalQuestions: Int,
    onRetry: () -> Unit,
) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text("Score: $score / $totalQuestions")
        Button(onClick = onRetry) {
            Text("Retry")
        }
    }
}

// trainingmode/TrainingModeScreen.kt

@Composable
fun TrainingModeScreen(
    viewModel: TrainingModeViewModel = hiltViewModel(),
    onNavigateBack: () -> Unit,
) {
    val uiState by viewModel.uiState.collectAsState()
    val selectedAnswerId by viewModel.selectedAnswerId.collectAsState()
    val isAnswerRevealed by viewModel.isAnswerRevealed.collectAsState()

    when (val state = uiState) {
        is TrainingModeUiState.Loading -> {
            LoadingIndicator()
        }
        
        is TrainingModeUiState.Ready -> {
            val currentQuestion = state.questions[state.currentIndex]
            
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp),
            ) {
                // Progress Bar
                TrainingModeProgressBar(
                    currentQuestion = state.currentIndex + 1,
                    totalQuestions = state.questions.size,
                    progress = state.progress,
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Question Card
                QuestionCard(
                    question = currentQuestion,
                    isSelected = selectedAnswerId != null,
                    isAnswerRevealed = isAnswerRevealed,
                    onAnswerSelect = { viewModel.selectAnswer(it) },
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Action Buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    Button(
                        onClick = onNavigateBack,
                        modifier = Modifier
                            .weight(1f)
                            .semantics {
                                contentDescription = "Exit training mode"
                            },
                    ) {
                        Text("Exit")
                    }

                    Button(
                        onClick = { if (!isAnswerRevealed) viewModel.revealAnswer() else viewModel.nextQuestion() },
                        enabled = selectedAnswerId != null,
                        modifier = Modifier
                            .weight(1f)
                            .semantics {
                                contentDescription = if (isAnswerRevealed) "Go to next question" else "Reveal answer"
                            },
                    ) {
                        Text(if (isAnswerRevealed) "Next" else "Reveal")
                    }
                }
            }
        }
        
        is TrainingModeUiState.Error -> {
            ErrorState(
                message = state.message,
                onRetry = { viewModel.retry() },
            )
        }
        
        is TrainingModeUiState.Complete -> {
            CompletionState(
                score = state.score,
                totalQuestions = state.totalQuestions,
                onRetry = { viewModel.retry() },
            )
        }
    }
}