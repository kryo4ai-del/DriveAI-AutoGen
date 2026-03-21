enum class OnboardingStep {
       GOAL_SELECTION,         // "What's your test date?"
       TIME_AVAILABILITY,      // "How much time can you practice daily?"
       LEARNING_STYLE,         // "Do you prefer depth or breadth?"
       DIFFICULTY_DIAGNOSIS,   // 5-question diagnostic
       HABIT_PREFERENCE,       // "When do you practice best?"
       REVIEW_CONFIRMATION     // "Here's your personalized config"
   }
   
   @HiltViewModel
   class OnboardingViewModel @Inject constructor(
       private val diagnosticService: DiagnosticService
   ) : ViewModel() {
       
       private val _currentStep = MutableStateFlow(OnboardingStep.GOAL_SELECTION)
       val currentStep: StateFlow<OnboardingStep> = _currentStep.asStateFlow()
       
       private val _userResponses = MutableStateFlow(UserOnboardingResponses())
       
       suspend fun completeOnboarding(): TrainingConfig {
           val responses = _userResponses.value
           val diagnosticResult = diagnosticService.runQuickDiagnostic()
           
           // Synthesize all inputs into one personalized config
           return TrainingConfig(
               sessionDuration = when (responses.dailyAvailableMinutes) {
                   in 0..5 -> 180
                   in 6..15 -> 600
                   else -> 900
               },
               questionsPerSession = when (responses.learningStyle) {
                   LearningStyle.DEPTH -> 15          // Fewer Qs, more elaboration
                   LearningStyle.BREADTH -> 25        // More Qs, quick coverage
                   LearningStyle.BALANCED -> 10
               },
               difficultyLevel = diagnosticResult.inferredLevel,
               adaptiveMode = true
           )
       }
   }