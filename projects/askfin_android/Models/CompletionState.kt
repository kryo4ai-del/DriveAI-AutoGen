@Composable
fun CompletionState(
    score: Int,
    totalQuestions: Int,
    onRetry: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.semantics {
                contentDescription = "Training complete. Score: $score of $totalQuestions"
            },
        ) {
            Text(
                text = "Training Complete! 🎉",
                style = MaterialTheme.typography.headlineSmall,
            )
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = "$score / $totalQuestions",
                style = MaterialTheme.typography.displaySmall,
                color = MaterialTheme.colorScheme.primary,
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "${(score.toFloat() / totalQuestions * 100).toInt()}% Correct",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            Button(onClick = onRetry) {
                Text("Try Again")
            }
        }
    }
}