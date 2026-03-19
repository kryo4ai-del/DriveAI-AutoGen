@Composable
fun ReadinessScoreScreen(viewModel: ReadinessScoreViewModel) {
    val readinessScore by viewModel.readinessScore.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()

    when {
        isLoading -> LoadingScreen()
        error != null -> ErrorScreen(
            message = error,
            onRetry = { viewModel.loadReadinessScore() }
        )
        readinessScore != null -> ReadinessScoreCard(readinessScore!!)
        else -> EmptyState()
    }
}

@Composable
private fun ErrorScreen(
    message: String,
    onRetry: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "⚠️ $message",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.error
        )
        Button(onClick = onRetry) {
            Text("Retry")
        }
    }
}