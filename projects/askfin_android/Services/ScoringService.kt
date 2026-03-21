// com.driveai.askfin.domain
object ScoringService {
    fun calculateScore(baseScore: Int, difficulty: DifficultyLevel): Int {
        return (baseScore * difficulty.scoreMultiplier()).toInt()
    }
}