// Models/EpisodicMemoryError.swift
import Foundation

enum EpisodicMemoryError: LocalizedError, Sendable {
    case databaseNotInitialized
    case databaseCorrupted(String)
    case invalidMemoryData
    case invalidMetadata(String)
    case queryFailed(String)
    case decodingFailed(String)
    case encodingFailed(String)
    case memoryNotFound(id: String)
    case diskSpaceLimited
    
    var errorDescription: String? {
        switch self {
        case .databaseNotInitialized:
            return NSLocalizedString(
                "Episodic memory database is not initialized.",
                comment: "Database error"
            )
        case .databaseCorrupted(let detail):
            return NSLocalizedString(
                "Episodic memory database is corrupted: \(detail)",
                comment: "Database corruption error"
            )
        case .invalidMemoryData:
            return NSLocalizedString(
                "Memory data is invalid.",
                comment: "Memory data error"
            )
        case .invalidMetadata(let detail):
            return NSLocalizedString(
                "Memory metadata could not be decoded: \(detail)",
                comment: "Metadata decode error"
            )
        case .queryFailed(let detail):
            return NSLocalizedString(
                "Memory query failed: \(detail)",
                comment: "Query error"
            )
        case .decodingFailed(let detail):
            return NSLocalizedString(
                "Failed to decode memory: \(detail)",
                comment: "Decode error"
            )
        case .encodingFailed(let detail):
            return NSLocalizedString(
                "Failed to encode memory: \(detail)",
                comment: "Encode error"
            )
        case .memoryNotFound(let id):
            return NSLocalizedString(
                "Memory with ID \(id) not found.",
                comment: "Not found error"
            )
        case .diskSpaceLimited:
            return NSLocalizedString(
                "Not enough disk space to save memory.",
                comment: "Disk space error"
            )
        }
    }
}