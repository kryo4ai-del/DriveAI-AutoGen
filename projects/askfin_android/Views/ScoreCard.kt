@Composable
fun ScoreCard(score: ReadinessScore) {
    Text(
        text = "Score: ${score.overallScore}",
        modifier = Modifier
            .semantics {
                contentDescription = "Overall score: ${score.overallScore}% recorded at ${score.getFormattedTimestamp()}"
            }
    )
}