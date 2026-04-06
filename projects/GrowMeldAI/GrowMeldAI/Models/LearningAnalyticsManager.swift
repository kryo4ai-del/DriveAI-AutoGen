import Foundation

@MainActor
public class LearningAnalyticsManager: ObservableObject {
    @Published public private(set) var examDate: Date
    @Published public private(set) var categoryPerformance: [String: Double]

    public init(examDate: Date = Date().addingTimeInterval(30 * 86400)) {
        self.examDate = examDate
        self.categoryPerformance = [:]
    }

    public struct ReadinessForecast {
        public let currentReadiness: Double
        public let daysUntilReadiness: Int
        public let status: ForecastStatus
    }

    public enum ForecastStatus {
        case onTrack
        case slipping
        case atRisk
    }

    public func readinessForecast() -> ReadinessForecast {
        let totalPerformance = categoryPerformance.values.reduce(0, +)
        let averagePerformance = totalPerformance / Double(categoryPerformance.count)

        let daysUntilExam = max(1, Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: examDate
        ).day ?? 1)

        let projectedReadiness = averagePerformance * Double(daysUntilExam)

        let status: ForecastStatus
        if projectedReadiness >= 0.8 {
            status = .onTrack
        } else if projectedReadiness >= 0.6 {
            status = .slipping
        } else {
            status = .atRisk
        }

        return ReadinessForecast(
            currentReadiness: averagePerformance,
            daysUntilReadiness: Int(projectedReadiness * Double(daysUntilExam)),
            status: status
        )
    }

    public func updatePerformance(for category: String, score: Double) {
        categoryPerformance[category] = score
    }
}