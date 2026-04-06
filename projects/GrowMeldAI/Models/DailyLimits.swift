import Foundation

/// Validated daily question and exam attempt quotas
public struct DailyLimits: Codable, Equatable, Sendable {
    public let questionsPerDay: Int
    public let examAttemptsPerDay: Int
    
    /// Designated initializer with validation
    public init?(questionsPerDay: Int, examAttemptsPerDay: Int) {
        guard questionsPerDay > 0, examAttemptsPerDay > 0 else {
            return nil
        }
        self.questionsPerDay = questionsPerDay
        self.examAttemptsPerDay = examAttemptsPerDay
    }
    
    /// Internal failable initializer for decoding
    init(questionsPerDay: Int, examAttemptsPerDay: Int) throws {
        guard questionsPerDay > 0, examAttemptsPerDay > 0 else {
            throw FreemiumError.invalidDailyLimits
        }
        self.questionsPerDay = questionsPerDay
        self.examAttemptsPerDay = examAttemptsPerDay
    }
}

extension DailyLimits {
    /// Default freemium limits
    public static let defaults = DailyLimits(questionsPerDay: 20, examAttemptsPerDay: 2)!
}

/// Current daily state — reset at midnight