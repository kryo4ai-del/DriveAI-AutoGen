@Singleton
class CompetenceCalculator @Inject constructor(
    private val ciCalculator: ConfidenceIntervalCalculator
) {
    fun calculateWeightedScore(
        answers: List<UserAnswer>,
        decayLambda: Double = 0.1
    ): CompetenceScore {
        if (answers.isEmpty()) {
            return CompetenceScore(
                value = 0f,
                confidenceInterval = ConfidenceInterval(0f, 0f, 0f),
                sampleSize = 0
            )
        }

        val correctCount = answers.count { it.isCorrect }
        val confidenceInterval = ciCalculator.calculate(correctCount, answers.size)

        // Apply recency weighting...
        val weightedScore = applyRecencyWeighting(answers, decayLambda, correctCount)

        return CompetenceScore(
            value = weightedScore,
            confidenceInterval = confidenceInterval,
            sampleSize = answers.size
        )
    }

    private fun applyRecencyWeighting(
        answers: List<UserAnswer>,
        decayLambda: Double,
        correctCount: Int
    ): Float {
        val now = System.currentTimeMillis()
        var weightedSum = 0.0
        var weightTotal = 0.0

        for ((index, answer) in answers.withIndex()) {
            val ageDays = (now - answer.answeredAt) / (1000.0 * 60 * 60 * 24)
            val recencyWeight = exp(-decayLambda * ageDays)
            val answerValue = if (answer.isCorrect) 1.0 else 0.0
            val streakBonus = calculateStreakBonus(answers, index)

            weightedSum += recencyWeight * (answerValue + streakBonus)
            weightTotal += recencyWeight
        }

        return ((weightedSum / weightTotal) * 100.0).toFloat().coerceIn(0f, 100f)
    }
}