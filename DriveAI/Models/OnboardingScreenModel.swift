// Models/OnboardingScreenModel.swift
import Foundation

struct OnboardingScreenModel {
    let title: String
    let description: String
    let imageName: String

    var formattedTitle: String {
        title.uppercased() // Example formatting
    }
}