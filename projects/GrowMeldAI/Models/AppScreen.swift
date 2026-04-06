// Models/UI/AppScreen.swift
import Foundation

enum AppScreen: Hashable {
    case onboarding(step: OnboardingStep)
    case home
    case categoryList
    case quiz(categoryID: String)
    case exam
    case results(examID: UUID)
    case profile
    
    enum OnboardingStep: Hashable {
        case welcome
        case examDate
        case categoryPreferences
        case complete
    }
}

// App/AppCoordinator.swift
import SwiftUI

@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentScreen: AppScreen = .home
}