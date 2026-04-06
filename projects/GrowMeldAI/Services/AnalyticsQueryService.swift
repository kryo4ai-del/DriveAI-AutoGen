// Modules/Analytics/Service/AnalyticsQueryService.swift

import Foundation

/// Computes analytics insights from event history.
@MainActor
final class AnalyticsQueryService {
    private let eventQueue: AnalyticsEventQueue
    private let logger = Logger(category: "AnalyticsQuery")
    
    init(eventQueue: AnalyticsEventQueue) {
        self.eventQueue = eventQueue
    }
    
    // MARK: - Public API
    
    func calculateConfidenceRatio() async -> Double {
        let events = await eventQueue.getAllEvents()
        
        let confidenceEvents = events.filter { 
            $0.eventType == .confidentAnswer || $0.eventType == .hesitantAnswer
        }
        
        guard !confidenceEvents.isEmpty else {
            return 0.5  // Default: neutral
        }
        
        let confidentCount = confidenceEvents.filter { 
            $0.eventType == .confidentAnswer 
        }.count
        
        return Double(confidentCount) / Double(confidenceEvents.count)
    }
    
    func identifyWeakCategories() async -> [String] {
        let events = await eventQueue.getAllEvents()
        
        let byCategory = Dictionary(grouping: events) { 
            $0.metadata["category_id"] ?? "unknown"
        }
        
        return byCategory
            .filter { 
                $0.value.filter({ $0.eventType == .hesitantAnswer }).count >= 2
            }
            .keys
            .sorted()
    }
    
    func calculateStreakDays() async -> Int {
        let events = await eventQueue.getAllEvents()
        
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: events) { event in
            calendar.component(.day, from: event.timestamp)
        }
        
        let sortedDays = grouped.keys.sorted(by: >)
        
        var streak = 0
        let today = calendar.component(.day, from: Date())
        
        for day in sortedDays {
            if day == today - streak {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
}