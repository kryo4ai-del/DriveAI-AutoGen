// Features/CameraOnboarding/Domain/Models/CameraQualityMetrics.swift
import Foundation

struct CameraQualityMetrics: Codable {
    let brightness: Float    // 0.0 - 1.0
    let contrast: Float      // 0.0 - 1.0
    let focus: Float         // 0.0 - 1.0 (via blur detection)
    let alignment: Float     // 0.0 - 1.0 (document edges detected)

    var qualityScore: Float {
        let scores = [brightness, contrast, focus, alignment]
        let validScores = scores.filter { $0 >= 0 && $0 <= 1 }
        return validScores.isEmpty ? 0 : Float(validScores.reduce(0, +)) / Float(validScores.count)
    }

    var isAcceptable: Bool {
        qualityScore >= 0.7
    }

    var feedbackMessage: String {
        switch qualityScore {
        case 0.85...:
            return "Ausgezeichnet! Führerschein gut sichtbar."
        case 0.70..<0.85:
            return "Gut! Leichte Anpassung empfohlen."
        case 0.65..<0.70:
            return "Achtung: Unscharf oder zu dunkel."
        default:
            return "Bildqualität zu niedrig. Bitte verbessern."
        }
    }
}