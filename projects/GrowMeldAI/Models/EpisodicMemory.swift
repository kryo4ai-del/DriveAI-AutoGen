// Models/EpisodicMemory.swift
import Foundation

/// Represents a memorable learning moment in the user's journey
struct EpisodicMemory: Identifiable, Codable {
    let id: String
    let type: MemoryType
    let timestamp: Date
    let categoryId: String?
    let metadata: MemoryMetadata
    let contextScore: Int // 0–100: relevance/importance
    
    init(
        type: MemoryType,
        categoryId: String? = nil,
        metadata: MemoryMetadata,
        contextScore: Int = 50
    ) {
        self.id = UUID().uuidString
        self.type = type
        self.timestamp = Date()
        self.categoryId = categoryId
        self.metadata = metadata
        self.contextScore = min(100, max(0, contextScore))
    }
}
