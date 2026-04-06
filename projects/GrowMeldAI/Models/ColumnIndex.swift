import Foundation
private func parseRow(_ row: [Binding?]) -> EpisodicMemory? {
    guard row.count >= 6 else { return nil }
    
    enum ColumnIndex {
        static let id = 0
        static let type = 1
        static let timestamp = 2
        static let categoryId = 3
        static let metadata = 4
        static let contextScore = 5
    }
    
    guard
        let id = row[ColumnIndex.id] as? String,
        let typeString = row[ColumnIndex.type] as? String,
        let type = MemoryType(rawValue: typeString),
        let timestamp = row[ColumnIndex.timestamp] as? Date,
        let metadataString = row[ColumnIndex.metadata] as? String,
        let metadataData = metadataString.data(using: .utf8)
    else { return nil }
    
    // ... rest
}