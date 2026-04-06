// Sources/Camera/Models/CaptureResult.swift
import Foundation

/// Result of a successful photo capture
struct CaptureResult: Equatable {
    let imageData: Data
    let timestamp: Date
    let examRelevance: ExamRelevance

    /// Explains how this capture helps with exam preparation
    var learningOutcome: String {
        switch examRelevance {
        case .licensePhoto:
            return "Dieses Foto hilft dir, die richtige Ausweisdokumentation für deine Prüfung zu üben."
        case .documentScan:
            return "Durch das Scannen von Dokumenten gewöhnst du dich an die Abläufe der echten Prüfung."
        case .practicePhoto:
            return "Jedes Foto trainiert deine Fähigkeit, wichtige Details für die Prüfung festzuhalten."
        }
    }
}

/// Types of exam-relevant captures
enum ExamRelevance: String, Codable, CaseIterable {
    case licensePhoto
    case documentScan
    case practicePhoto
}