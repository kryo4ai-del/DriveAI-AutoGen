// In FunnelStage enum:
enum FunnelStage: String, CaseIterable {
    case appLaunch
    case onboardingStart
    case onboardingComplete
    case firstQuiz
    case firstQuestion
    case quizCompletion
    case examSimulation
    case examPass
    
    var accessibilityLabel: String {
        switch self {
        case .appLaunch:
            return NSLocalizedString("funnel.app_launch", 
                value: "App launched", comment: "Funnel stage")
        case .onboardingStart:
            return NSLocalizedString("funnel.onboarding_start", 
                value: "Started setup", comment: "Funnel stage")
        case .onboardingComplete:
            return NSLocalizedString("funnel.onboarding_complete", 
                value: "Setup completed", comment: "Funnel stage")
        case .firstQuiz:
            return NSLocalizedString("funnel.first_quiz", 
                value: "First quiz started", comment: "Funnel stage")
        case .firstQuestion:
            return NSLocalizedString("funnel.first_question", 
                value: "First question answered", comment: "Funnel stage")
        case .quizCompletion:
            return NSLocalizedString("funnel.quiz_completion", 
                value: "Quiz completed", comment: "Funnel stage")
        case .examSimulation:
            return NSLocalizedString("funnel.exam_simulation", 
                value: "Exam simulation started", comment: "Funnel stage")
        case .examPass:
            return NSLocalizedString("funnel.exam_pass", 
                value: "Exam passed", comment: "Funnel stage")
        }
    }
    
    var accessibilityHint: String {
        switch self {
        case .onboardingStart:
            return NSLocalizedString("funnel.onboarding_start.hint",
                value: "Enter your exam date to personalize your learning plan.",
                comment: "Onboarding hint")
        case .firstQuiz:
            return NSLocalizedString("funnel.first_quiz.hint",
                value: "Choose a category and answer practice questions.",
                comment: "First quiz hint")
        case .examSimulation:
            return NSLocalizedString("funnel.exam_simulation.hint",
                value: "Take a full 30-question test to assess your readiness.",
                comment: "Exam simulation hint")
        default:
            return ""
        }
    }
}