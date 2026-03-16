import Foundation
import SwiftUI

struct ExamReadiness: Identifiable, Codable {
    let id: UUID
    let overallScore: Double
    let categoryScores: [String: Double]
    let isReady: Bool
    let weakCategories: [String]
    let readinessLevel: ReadinessLevel
    let calculatedAt: Date
    let examDate: Date
    let daysUntilExam: Int

    init(
        id: UUID = UUID(),
        overallScore: Double = 0,
        categoryScores: [String: Double] = [:],
        isReady: Bool = false,
        weakCategories: [String] = [],
        readinessLevel: ReadinessLevel = .notReady,
        calculatedAt: Date = Date(),
        examDate: Date = Date(),
        daysUntilExam: Int = 0
    ) {
        self.id = id
        self.overallScore = overallScore
        self.categoryScores = categoryScores
        self.isReady = isReady
        self.weakCategories = weakCategories
        self.readinessLevel = readinessLevel
        self.calculatedAt = calculatedAt
        self.examDate = examDate
        self.daysUntilExam = daysUntilExam
    }

    var readinessScore: Double { overallScore }

    enum ReadinessLevel: String, Codable {
        case notReady
        case onTrack
        case exceeding

        var color: Color {
            switch self {
            case .notReady: return .red
            case .onTrack: return .orange
            case .exceeding: return .green
            }
        }

        init(score: Double) {
            switch score {
            case 70...: self = .exceeding
            case 50..<70: self = .onTrack
            default: self = .notReady
            }
        }

        var label: String {
            switch self {
            case .notReady: return "Nicht bereit"
            case .onTrack: return "Auf Kurs"
            case .exceeding: return "Hervorragend"
            }
        }
    }
}
