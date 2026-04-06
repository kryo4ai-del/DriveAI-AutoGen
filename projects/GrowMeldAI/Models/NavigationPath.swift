import Foundation

enum NavigationPath: Hashable {
    case onboarding
    case home
    case question(Category?)
    case categoryList
    case exam
    case result(ExamResult)
    case profile
    case reviewMistakes(ExamAttempt)
}