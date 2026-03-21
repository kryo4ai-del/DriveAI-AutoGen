@HiltViewModel
   class TrainingSessionFlowViewModel @Inject constructor(
       private val diagnosticService: DiagnosticService,
       private val difficultyPredictor: DifficultyPredictor
   ) : ViewModel() {
       
       suspend fun runDiagnostic(): DiagnosticResult {
           // 5 mixed-difficulty questions
           // Measure: correctness, time-to-answer, confidence
           // Infer: user's ZPD (zone of proximal development)
           // Return: recommended starting difficulty
       }
       
       fun recommendConfig(goal: SessionGoal): TrainingConfig {
           val userHistory = /* fetch from repo */
           val predictedLevel = difficultyPredictor.predictOptimalDifficulty(
               goal = goal,
               history = userHistory
           )
           return TrainingConfig(
               sessionDuration = when (goal) {
                   SessionGoal.LEARN -> 600        // 10 min for deep learning
                   SessionGoal.REVIEW -> 300       // 5 min for quick refresh
                   SessionGoal.TEST_PREP -> 900    // 15 min full pressure
               },
               difficultyLevel = predictedLevel,
               adaptiveMode = true
           )
       }
   }