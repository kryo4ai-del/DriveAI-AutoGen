// Models/SessionRecord.swift
import Foundation

struct SessionRecord: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let date: Date
    let technique: String
    let durationSeconds: Int
    let completedCycles: Int
    
    enum SessionError: LocalizedError {
        case invalidDuration
        case invalidCycles
        case invalidTechnique
        
        var errorDescription: String? {
            switch self {
            case .invalidDuration:
                return "Session duration must be greater than 0 seconds"
            case .invalidCycles:
                return "Completed cycles cannot be negative"
            case .invalidTechnique:
                return "Invalid breathing technique"
            }
        }
    }
    
    /// Creates a session record with validation.
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided)
    ///   - date: Session date (defaults to now)
    ///   - technique: Selected breathing technique
    ///   - durationSeconds: Session duration in seconds (must be > 0)
    ///   - completedCycles: Number of completed breathing cycles (must be >= 0)
    /// - Throws: SessionError if validation fails
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        technique: BreathingTechnique,
        durationSeconds: Int,
        completedCycles: Int
    ) throws {
        guard durationSeconds > 0 else {
            throw SessionError.invalidDuration
        }
        guard completedCycles >= 0 else {
            throw SessionError.invalidCycles
        }
        
        self.id = id
        self.date = date
        self.technique = technique.rawValue
        self.durationSeconds = max(durationSeconds, 1) // Minimum 1 second
        self.completedCycles = completedCycles
    }
    
    /// The technique as an enum for type-safe access.
    var techniqueEnum: BreathingTechnique {
        BreathingTechnique(rawValue: technique) ?? .calmBreathing
    }
    
    /// Duration in minutes (rounded down).
    var durationMinutes: Int {
        durationSeconds / 60
    }
}