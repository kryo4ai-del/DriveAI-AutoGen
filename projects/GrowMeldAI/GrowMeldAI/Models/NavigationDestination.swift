enum NavigationDestination {
    case onboarding
    case home
    case category(Category)
    case question(Question)
    case examSimulation
    case examResult(ExamAttempt)
    case profile
}