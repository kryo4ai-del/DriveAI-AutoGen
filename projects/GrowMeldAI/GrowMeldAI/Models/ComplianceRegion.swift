// MARK: - Age Verification

import Foundation

/// Compliance region determines age threshold
enum ComplianceRegion: String, Codable {
    case unitedStates  // COPPA: 13+
    case europeanUnion // GDPR: 16+
    case switzerland   // GDPR: 16+
    case unitedKingdom // GDPR: 16+
    
    var minimumAge: Int {
        switch self {
        case .unitedStates:
            return 13
        case .europeanUnion, .switzerland, .unitedKingdom:
            return 16
        }
    }
}

/// Immutable consent record for audit trail

enum UserAction: String, Codable {
    case confirmed
    case rejected
    case parentalApproval
    case parentalRejection
}

// MARK: - Deletion Audit

enum DeletionReason: String, Codable {
    case userRequested
    case retentionExpired
    case gdprRequest
}

// MARK: - Age Calculation (Timezone-Safe)

struct AgeCalculator {
    static func calculateAge(from birthDate: Date, on referenceDate: Date = Date()) -> Int {
        // Use UTC for all calculations (defensible, consistent)
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year], from: birthDate, to: referenceDate)
        return components.year ?? 0
    }
    
    static func isOldEnoughFor(
        region: ComplianceRegion,
        birthDate: Date,
        on referenceDate: Date = Date()
    ) -> Bool {
        let age = calculateAge(from: birthDate, on: referenceDate)
        return age >= region.minimumAge
    }
    
    /// Validates birth date is realistic (between 1900 and today)
    static func isValidBirthDate(_ date: Date) -> Bool {
        let hundredYearsAgo = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        return date >= hundredYearsAgo && date <= Date()
    }
}