@Preview(showBackground = true)
@Composable
fun ReadinessScoreCardPreview() {
    ReadinessScoreCard(
        readinessScore = ReadinessScore(
            currentScore = 75,
            previousScore = 60,
            trendPercentage = 25f,
            milestones = listOf(
                Milestone("m1", 20, "Beginner", "🌱", isUnlocked = true),
                Milestone("m2", 50, "Intermediate", "📈", isUnlocked = true),
                Milestone("m3", 80, "Advanced", "🚀", isUnlocked = false)
            )
        )
    )
}