// DriveAI/Features/TrialMechanik/Domain/Models/MotivationalMessage.swift
import Foundation

struct MotivationalMessage: Equatable {
    let title: String
    let subtitle: String
    let urgency: Urgency

    enum Urgency {
        case low
        case medium
        case high
    }
}