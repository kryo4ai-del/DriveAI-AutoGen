// ViewModels/OnboardingViewModel.swift

import UserNotifications
import Combine

enum OnboardingStep: Hashable {
    case welcome
    case examDate
    case notificationConsent
    case complete
}

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    
    func advance() {
        switch currentStep {
        case .welcome:
            currentStep = .examDate
        case .examDate:
            currentStep = .notificationConsent
        case .notificationConsent:
            currentStep = .complete
        case .complete:
            break
        }
    }
}