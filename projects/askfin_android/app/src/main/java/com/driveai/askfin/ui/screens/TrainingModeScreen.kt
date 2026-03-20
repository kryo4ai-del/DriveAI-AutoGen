package com.driveai.askfin.ui.screens

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