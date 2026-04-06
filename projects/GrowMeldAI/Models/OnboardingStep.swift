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