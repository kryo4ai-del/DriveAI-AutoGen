// MARK: - Modules/Data/Services/SessionPersistenceService.swift
import Foundation
@MainActor
protocol SessionPersistenceService: AnyObject {
    func saveSessionState<T: Codable>(_ state: T, for sessionId: UUID) async throws
    func loadSessionState<T: Codable>(for sessionId: UUID, as type: T.Type) async throws -> T?
    func deleteSessionState(for sessionId: UUID) async throws
    func listActiveSessions() async throws -> [UUID]
}

@MainActor
class LocalSessionPersistenceService: SessionPersistenceService {
    private let fileManager = FileManager.default
    private let sessionsDirectory: URL
    
    init() {
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        self.sessionsDirectory = paths[0].appendingPathComponent("sessions")
        try? fileManager.createDirectory(at: sessionsDirectory, withIntermediateDirectories: true)
    }
    
    func saveSessionState<T: Codable>(_ state: T, for sessionId: UUID) async throws {
        let fileURL = sessionsDirectory.appendingPathComponent("\(sessionId.uuidString).json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(state)
        try data.write(to: fileURL, options: .atomic)
    }
    
    func loadSessionState<T: Codable>(for sessionId: UUID, as type: T.Type) async throws -> T? {
        let fileURL = sessionsDirectory.appendingPathComponent("\(sessionId.uuidString).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
    
    func deleteSessionState(for sessionId: UUID) async throws {
        let fileURL = sessionsDirectory.appendingPathComponent("\(sessionId.uuidString).json")
        try fileManager.removeItem(at: fileURL)
    }
    
    func listActiveSessions() async throws -> [UUID] {
        let contents = try fileManager.contentsOfDirectory(at: sessionsDirectory, includingPropertiesForKeys: nil)
        return contents.compactMap { url in
            let filename = url.deletingPathExtension().lastPathComponent
            return UUID(uuidString: filename)
        }
    }
}