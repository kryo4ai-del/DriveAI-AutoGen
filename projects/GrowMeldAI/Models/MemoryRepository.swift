import Foundation
protocol MemoryRepository {
    func insert(_ memory: EpisodicMemory) async throws
    func fetch(categoryID: String) async throws -> [EpisodicMemory]
    func deleteOlderThan(_ date: Date) async throws
}

// Class MemoryService declared in Services/MemoryService.swift
