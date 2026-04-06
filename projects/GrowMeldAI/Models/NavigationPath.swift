import Foundation

enum AppNavigationDestination: Hashable {
    case onboarding
    case home
    case question(QuizCategory?)
    case categoryList
    case exam
    case result(ExamResult)
    case profile
    case reviewMistakes(ExamAttempt)
}

typealias AppNavigationPath = AppNavigationDestination