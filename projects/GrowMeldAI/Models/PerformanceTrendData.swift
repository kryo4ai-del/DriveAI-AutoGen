// DriveAI/Features/GrowthTracking/Models/PerformanceTrendData.swift
import Foundation
import SwiftUI

/// Single data point for performance trend visualization
struct PerformanceTrendData: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let correctPercentage: Double  // 0.0...1.0
    let attemptCount: Int
    let fahrtempo: Fahrtempo  // velocity indicator

    enum Fahrtempo: String, Codable, Equatable {
        case accelerating = "accelerating"
        case steady = "steady"
        case declining = "declining"

        var displayName: String {
            switch self {
            case .accelerating: return "Tempo erhöht"
            case .steady: return "Tempo stabil"
            case .declining: return "Tempo reduziert"
            }
        }

        var systemImageName: String {
            switch self {
            case .accelerating: return "arrow.up"
            case .steady: return "arrow.right"
            case .declining: return "arrow.down"
            }
        }

        var color: Color {
            switch self {
            case .accelerating: return .green
            case .steady: return .blue
            case .declining: return .orange
            }
        }
    }
}