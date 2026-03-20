package com.driveai.askfin.ui.components
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.runtime.Composable

data class ReadinessScore(
    val currentScore: Int,
    val previousScore: Int,
    val trendPercentage: Float,
    val milestones: List<Milestone>
)

data class Milestone(
    val name: String,
    val achievedDate: Long? = null,
    val score: Int? = null,
    val label: String? = null,
    val icon: String? = null,
    val isUnlocked: Boolean = false
)

@Composable
fun ReadinessScoreCard(score: ReadinessScore) {
}

@Preview(showBackground = true)
@Composable
fun ReadinessScoreCardPreview() {
    ReadinessScoreCard(
        score = ReadinessScore(
            currentScore = 75,
            previousScore = 60,
            trendPercentage = 25f,
            milestones = listOf(
                Milestone("m1", score = 20, label = "Beginner", icon = "🌱", isUnlocked = true),
                Milestone("m2", score = 50, label = "Intermediate", icon = "📈", isUnlocked = true),
                Milestone("m3", score = 80, label = "Advanced", icon = "🚀", isUnlocked = false)
            )
        )
    )
}