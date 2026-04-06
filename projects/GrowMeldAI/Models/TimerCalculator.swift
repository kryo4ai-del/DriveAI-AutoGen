import Foundation

@MainActor
final class TimerCalculator {
    static func elapsedTime(
        startDate: Date,
        pauseStartDate: Date? = nil,
        cumulativePausedDuration: TimeInterval = 0
    ) -> TimeInterval {
        let totalElapsed = Date().timeIntervalSince(startDate)
        let currentPauseDuration = pauseStartDate.map { Date().timeIntervalSince($0) } ?? 0
        return totalElapsed - cumulativePausedDuration - currentPauseDuration
    }

    static func daysRemaining(until targetDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return max(0, components.day ?? 0)
    }

    static func formatTimeRemaining(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}