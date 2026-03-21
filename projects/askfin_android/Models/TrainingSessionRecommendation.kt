data class TrainingSessionRecommendation(
       val config: TrainingConfig,
       val topicName: String,
       val daysSinceLastReview: Int,
       val estimatedPassProbability: Float,  // 0.0–1.0
       val weaknessLevel: DifficultyLevel,   // Inferred from user history
       val reviewUrgency: ReviewUrgency       // OVERDUE, OPTIMAL, EARLY, NOT_READY
   )
   
   enum class ReviewUrgency {
       OVERDUE,      // >10 days since last review
       OPTIMAL,      // 3–7 days (peak retention window)
       EARLY,        // <3 days (still fresh)
       NOT_READY     // <24 hours (cognitive fatigue risk)
   }