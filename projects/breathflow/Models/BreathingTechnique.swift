// Models/BreathingTechnique.swift
import Foundation

enum BreathingTechnique: String, CaseIterable, Codable, Sendable {
    case fourSevenEight
    case boxBreathing
    case calmBreathing
    
    var displayName: String {
        switch self {
        case .fourSevenEight:
            return "4-7-8 Breathing"
        case .boxBreathing:
            return "Box Breathing"
        case .calmBreathing:
            return "Calm Breathing"
        }
    }
    
    var description: String {
        switch self {
        case .fourSevenEight:
            return "Deep relaxation technique with extended hold phase"
        case .boxBreathing:
            return "Balanced breathing pattern used by Navy SEALs"
        case .calmBreathing:
            return "Gentle pattern for everyday stress relief"
        }
    }
    
    var icon: String {
        switch self {
        case .fourSevenEight:
            return "lungs.fill"
        case .boxBreathing:
            return "square.fill"
        case .calmBreathing:
            return "leaf.fill"
        }
    }
    
    var inhaleSeconds: Int {
        switch self {
        case .fourSevenEight:
            return 4
        case .boxBreathing:
            return 4
        case .calmBreathing:
            return 5
        }
    }
    
    var holdSeconds: Int {
        switch self {
        case .fourSevenEight:
            return 7
        case .boxBreathing:
            return 4
        case .calmBreathing:
            return 5
        }
    }
    
    var exhaleSeconds: Int {
        switch self {
        case .fourSevenEight:
            return 8
        case .boxBreathing:
            return 4
        case .calmBreathing:
            return 5
        }
    }
    
    var totalCycleDuration: Int {
        inhaleSeconds + holdSeconds + exhaleSeconds
    }
}