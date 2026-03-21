// Domain layer: com.driveai.askfin.domain.scoring.ScoringCalculator.kt
object ScoringCalculator {
    fun getMultiplier(difficulty: DifficultyLevel): Float = when (difficulty) {
        DifficultyLevel.EASY -> 1.0f
        DifficultyLevel.MEDIUM -> 1.5f
        DifficultyLevel.HARD -> 2.0f
    }
    
    fun calculateSessionScore(rawScore: Int, difficulty: DifficultyLevel): Int {
        return (rawScore * getMultiplier(difficulty)).toInt()
    }
}