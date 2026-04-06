import Foundation
import os.log

protocol ConfidenceHistoryServiceProtocol {
    func getConfidenceTrend(
        for category: String,
        lookbackDays: Int
    ) async throws -> ConfidenceTrend
}

final class ConfidenceHistoryService: ConfidenceHistoryServiceProtocol {
    private let dataService: LocalDataServiceProtocol
    private let logger = Logger(subsystem: "com.driveai.memory", category: "history")
    
    init(dataService: LocalDataServiceProtocol) {
        self.dataService = dataService
    }
    
    func getConfidenceTrend(
        for category: String,
        lookbackDays: Int = 7
    ) async throws -> ConfidenceTrend {
        let cutoffDate = Date().addingTimeInterval(-Double(lookbackDays) * 86400)
        
        let history = try await dataService.fetchConfidenceHistory(
            category: category,
            since: cutoffDate
        )
        
        guard history.count >= 2 else {
            logger.debug("Not enough history for \(category) (count: \(history.count))")
            return .stable
        }
        
        let first = history.first!.confidence
        let last = history.last!.confidence
        let delta = last - first
        let threshold = 0.05  // 5% change = significant
        
        if delta > threshold {
            return .improving
        } else if delta < -threshold {
            return .declining
        } else {
            return .stable
        }
    }
}

// MARK: - Data Model

struct ConfidenceHistoryEntry {
    let timestamp: Date
    let category: String
    let confidence: Double
}