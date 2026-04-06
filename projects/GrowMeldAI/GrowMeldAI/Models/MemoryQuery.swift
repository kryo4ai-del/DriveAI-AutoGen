// Models/MemoryQuery.swift
import Foundation

struct MemoryQuery {
    let types: [MemoryType]?
    let categoryId: String?
    let dateRange: DateRange?
    let limit: Int
    let offset: Int
    
    struct DateRange {
        let start: Date
        let end: Date
    }
    
    init(
        types: [MemoryType]? = nil,
        categoryId: String? = nil,
        dateRange: DateRange? = nil,
        limit: Int = 20,
        offset: Int = 0
    ) {
        self.types = types
        self.categoryId = categoryId
        self.dateRange = dateRange
        self.limit = limit
        self.offset = offset
    }
    
    static var recent(limit: Int = 20) -> MemoryQuery {
        MemoryQuery(limit: limit)
    }
    
    static var thisWeek(types: [MemoryType]? = nil) -> MemoryQuery {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -7, to: end) ?? end
        return MemoryQuery(
            types: types,
            dateRange: .init(start: start, end: end),
            limit: 50
        )
    }
}