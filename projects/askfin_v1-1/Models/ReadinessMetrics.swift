import Foundation
import SwiftUI

/// Container for readiness component metrics
struct ReadinessMetrics: Codable, Equatable {
    let timeInvestedMinutes: Int
    let currentStreakDays: Int
    let categoriesStarted: Int
    let categoriesCompleted: Int
    let lastSessionDate: Date
    
    // MARK: - Computed Properties
    
    var timeInvestedHours: Double {
        Double(timeInvestedMinutes) / 60.0
    }
    
    var timeInvestedFormatted: String {
        let hours = timeInvestedMinutes / 60
        let mins = timeInvestedMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)min"
        }
        return "\(mins)min"
    }
    
    var streakMultiplier: Double {
        // Used in readiness scoring: (current / max capped at 30 days)
        min(Double(currentStreakDays) / 30.0, 1.0)
    }
    
    var categoryCompletionRatio: Double {
        guard categoriesStarted > 0 else { return 0 }
        return Double(categoriesCompleted) / Double(categoriesStarted)
    }
    
    var categoryCompletionPercentage: Int {
        Int(categoryCompletionRatio * 100)
    }
    
    var daysSinceLastSession: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: lastSessionDate, to: now)
        return components.day ?? 0
    }
    
    // MARK: - Preview Data
    
    static let preview = ReadinessMetrics(
        timeInvestedMinutes: 420,
        currentStreakDays: 7,
        categoriesStarted: 8,
        categoriesCompleted: 6,
        lastSessionDate: Date().addingTimeInterval(-3600)
    )
    
    static let previewMinimal = ReadinessMetrics(
        timeInvestedMinutes: 15,
        currentStreakDays: 1,
        categoriesStarted: 1,
        categoriesCompleted: 0,
        lastSessionDate: Date()
    )
    
    static let previewExtensive = ReadinessMetrics(
        timeInvestedMinutes: 2400,
        currentStreakDays: 28,
        categoriesStarted: 10,
        categoriesCompleted: 10,
        lastSessionDate: Date().addingTimeInterval(-1800)
    )
}