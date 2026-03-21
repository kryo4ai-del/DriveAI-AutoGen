data class SessionExpectation(
       val estimatedDuration: Int,              // seconds
       val estimatedQuestionCount: Int,
       val targetAccuracy: Float,               // 0.7 = 70%
       val expectedDifficulty: DifficultyLevel,
       val successCondition: String,
       val riskStatement: String
   )
   
   // In ViewModel
   fun generateExpectation(config: TrainingConfig): SessionExpectation {
       val estimatedTime = (config.sessionDuration / 60).toString()
       val difficulty = config.difficultyLevel.name.lowercase()
       
       return SessionExpectation(
           estimatedDuration = config.sessionDuration,
           estimatedQuestionCount = config.questionsPerSession,
           targetAccuracy = when (config.difficultyLevel) {
               DifficultyLevel.EASY -> 0.85f
               DifficultyLevel.MEDIUM -> 0.75f
               DifficultyLevel.HARD -> 0.65f
           },
           expectedDifficulty = config.difficultyLevel,
           successCondition = 
               "You'll answer $${config.questionsPerSession} questions in $estimatedTime minutes. " +
               "Success = ${(config.difficultyLevel.targetAccuracy * 100).toInt()}% correct.",
           riskStatement = 
               "If you score below 60%, these topics will reappear in 24 hours."
       )
   }