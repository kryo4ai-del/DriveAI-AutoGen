// Features/Onboarding/Models/OnboardingRoute.swift
import SwiftUI

enum OnboardingRoute: Hashable {
    case welcome
    case camera
    case profileForm(userProfile: UserProfile)
    case confirmation(userProfile: UserProfile, profileImage: UIImage?)
    case completed(userProfile: UserProfile)
}