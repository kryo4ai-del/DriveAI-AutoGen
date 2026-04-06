import Foundation

enum NavigationPath: Hashable {
    case onboarding
    case home
    case question(QuizApp.Category?)
    case categoryList
    case exam
    case result(QuizApp.ExamResult)
    case profile
    case reviewMistakes(QuizApp.ExamAttempt)
}