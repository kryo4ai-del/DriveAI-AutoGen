// Presentation/Helpers/Navigation.swift
enum NavigationPath: Hashable {
    case onboarding
    case home
    case question(Category?)        // Optional filter
    case categoryList
    case exam
    case result(ExamResult)
    case profile
    case reviewMistakes(ExamAttempt)
}

// App/AppCoordinator.swift
@MainActor

// App/DriveAIApp.swift
@main