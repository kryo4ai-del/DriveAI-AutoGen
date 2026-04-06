import Foundation

/// Fluent query builder for performance metrics with validation
struct PerformanceQuery {
    var categoryIds: [String]?
    var dateRange: DateInterval?
    var minAccuracy: Double?
    var limit: Int?
    var offset: Int = 0
    
    // MARK: - Builder Methods with Validation
    
    func withCategory(_ id: String) -> Self {
        precondition(!id.trimmingCharacters(in: .whitespaces).isEmpty, "Category ID cannot be empty")
        var copy = self
        copy.categoryIds = (copy.categoryIds ?? []) + [id]
        return copy
    }
    
    func withCategories(_ ids: [String]) -> Self {
        precondition(!ids.isEmpty, "Category IDs array cannot be empty")
        precondition(ids.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }, "All category IDs must be non-empty")
        var copy = self
        copy.categoryIds = ids
        return copy
    }
    
    func withDateRange(_ start: Date, _ end: Date) -> Self {
        precondition(start <= end, "Start date must not be after end date")
        var copy = self
        copy.dateRange = DateInterval(start: start, end: end)
        return copy
    }
    
    func withMinimumAccuracy(_ accuracy: Double) -> Self {
        precondition(0.0...1.0 ~= accuracy, "Accuracy must be between 0.0 and 1.0")
        var copy = self
        copy.minAccuracy = accuracy
        return copy
    }
    
    func withLimit(_ limit: Int) -> Self {
        precondition(limit > 0, "Limit must be positive")
        var copy = self
        copy.limit = limit
        return copy
    }
    
    func withOffset(_ offset: Int) -> Self {
        precondition(offset >= 0, "Offset cannot be negative")
        var copy = self
        copy.offset = offset
        return copy
    }
    
    // MARK: - Convenience Methods
    
    static func recentDays(_ days: Int, categoryId: String? = nil) -> Self {
        precondition(days > 0, "Days must be positive")
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -days, to: end) ?? end
        
        var query = Self().withDateRange(start, end)
        if let catId = categoryId {
            query = query.withCategory(catId)
        }
        return query
    }
    
    static func today(categoryId: String? = nil) -> Self {
        let now = Date()
        let today = Calendar.current.startOfDay(for: now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? now
        
        var query = Self().withDateRange(today, tomorrow)
        if let catId = categoryId {
            query = query.withCategory(catId)
        }
        return query
    }
    
    static func lastWeek(categoryId: String? = nil) -> Self {
        Self.recentDays(7, categoryId: categoryId)
    }
    
    static func lastMonth(categoryId: String? = nil) -> Self {
        Self.recentDays(30, categoryId: categoryId)
    }
}