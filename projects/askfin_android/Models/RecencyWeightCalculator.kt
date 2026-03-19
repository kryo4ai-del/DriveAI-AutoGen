/**
 * Applies time-decay weighting to answers.
 * Newer answers have higher weight, older answers decay exponentially.
 */
class RecencyWeightCalculator {
    
    data class WeightedAnswer(
        val answer: UserAnswer,
        val weight: Double,      // [0..1]
        val ageDays: Double
    )

    /**
     * Weights all answers by recency + streak bonuses.
     *
     * @param answers Sorted by timestamp (oldest first)
     * @param decayLambda Exponential decay rate (typical: 0.1-0.15)
     * @param streakWindowDays Consecutive correct answers within this window count as streak
     * @return Weighted answers and total weight sum
     */
    fun calculateWeights(
        answers: List<UserAnswer>,
        decayLambda: Double = 0.1,
        streakWindowDays: Double = 1.0
    ): Pair<List<WeightedAnswer>, Double> {
        if (answers.isEmpty()) return Pair(emptyList(), 0.0)

        val now = System.currentTimeMillis()
        val oneDay = 1000L * 60 * 60 * 24

        val weightedAnswers = answers.mapIndexed { index, answer ->
            val ageDays = (now - answer.answeredAt) / oneDay.toDouble()
            
            // Exponential recency decay
            val recencyWeight = exp(-decayLambda * ageDays)
            
            // Streak bonus: consecutive correct within window
            val streakBonus = if (answer.isCorrect) {
                calculateStreakBonus(answers, index, streakWindowDays)
            } else {
                0.0
            }
            
            // Combined weight: (1 + streak bonus) × recency
            val finalWeight = recencyWeight * (1.0 + streakBonus)

            WeightedAnswer(answer, finalWeight, ageDays)
        }

        val totalWeight = weightedAnswers.sumOf { it.weight }
        return Pair(weightedAnswers, totalWeight)
    }

    private fun calculateStreakBonus(
        answers: List<UserAnswer>,
        currentIndex: Int,
        streakWindowDays: Double
    ): Double {
        val currentTime = answers[currentIndex].answeredAt
        val windowMs = (streakWindowDays * 24 * 60 * 60 * 1000).toLong()
        
        var streak = 1
        for (i in (currentIndex - 1) downTo 0) {
            val timeDiff = currentTime - answers[i].answeredAt
            if (timeDiff <= windowMs && answers[i].isCorrect) {
                streak++
            } else {
                break
            }
        }

        // +5% per consecutive, max +25% (5 streak)
        return (streak.coerceAtMost(5) * 0.05)
    }
}