// DriveAI/Features/TrialMechanik/Presentation/ViewModels/TrialStatusViewModel.swift
import Foundation
import SwiftUI

class TrialStatusViewModel: ObservableObject {
    @Published var message: MotivationalMessage = .init(
        title: "Bereit für die Prüfung?",
        subtitle: "Beginne mit den ersten Fragen",
        urgency: .low
    )

    private let motivationalStrategy: MotivationalStrategy

    init(motivationalStrategy: MotivationalStrategy = MotivationalStrategy()) {
        self.motivationalStrategy = motivationalStrategy
    }

    func updateMessage(_ journey: TrialJourney) {
        let totalQuestions = journey.questionsAllowedPerDay
        let daysPercent = Double(journey.daysRemaining) / 7.0
        let questionsPercent = Double(journey.questionsAnsweredToday) / Double(totalQuestions)

        let message = motivationalStrategy.feedback(
            daysPercent: daysPercent,
            questionsPercent: questionsPercent,
            daysRemaining: journey.daysRemaining
        )

        self.message = message
    }
}