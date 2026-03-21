data class UserPracticeHabit(
       val userId: String,
       val lastSessionTime: LocalDateTime,
       val consecutiveSessionDays: Int,
       val preferredSessionTime: LocalTime,      // e.g., 7:00 AM
       val preferredSessionDuration: Int,        // e.g., 300s
       val preferredDifficulty: DifficultyLevel,
       val nextReviewTopics: List<String>        // What to study next
   )
   
   // In ViewModel
   fun suggestNextSession(): TrainingConfig {
       val habit = habitRepository.getOrCreate(userId)
       val nextTopics = reviewScheduler.getTopicsForReview(userId)
       
       // Recommend a config that matches user's established rhythm
       return TrainingConfig(
           sessionDuration = habit.preferredSessionDuration,
           questionsPerSession = 10,  // Default
           difficultyLevel = when {
               habit.consecutiveSessionDays > 7 -> DifficultyLevel.HARD
               habit.consecutiveSessionDays > 3 -> DifficultyLevel.MEDIUM
               else -> DifficultyLevel.EASY
           },
           adaptiveMode = true
       )
   }