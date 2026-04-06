import Foundation

// MARK: - Supporting Types

enum ComplianceRegion: String, Codable {
    case germany = "DE"
    case austria = "AT"
    case switzerland = "CH"
    case other = "OTHER"
}

enum UserAction: String, Codable {
    case accepted
    case declined
    case skipped
}

struct ConsentRecord: Codable, Identifiable {
    let id: UUID
    let birthYear: Int
    let birthMonth: Int
    let birthDay: Int
    let recordedDate: Date
    let userAction: UserAction
    let appVersion: String
    let deviceHash: String
    let complianceRegion: ComplianceRegion
}

enum ConsentError: LocalizedError {
    case invalidBirthDate
    case recordingFailed(reason: String)
    case underageUser

    var errorDescription: String? {
        switch self {
        case .invalidBirthDate:
            return "The provided birth date is invalid."
        case .recordingFailed(let reason):
            return "Consent recording failed: \(reason)"
        case .underageUser:
            return "User does not meet the minimum age requirement."
        }
    }
}

// MARK: - Protocol

protocol ConsentRecordingService {
    func recordConsent(
        birthDate: Date,
        region: ComplianceRegion,
        action: UserAction
    ) -> Result<ConsentRecord, ConsentError>
}

// MARK: - Mock Implementation

class MockConsentRecordingService: ConsentRecordingService {
    var recordedConsents: [ConsentRecord] = []

    func recordConsent(
        birthDate: Date,
        region: ComplianceRegion,
        action: UserAction
    ) -> Result<ConsentRecord, ConsentError> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate)

        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return .failure(.invalidBirthDate)
        }

        let record = ConsentRecord(
            id: UUID(),
            birthYear: year,
            birthMonth: month,
            birthDay: day,
            recordedDate: Date(),
            userAction: action,
            appVersion: "1.0",
            deviceHash: "hash",
            complianceRegion: region
        )
        recordedConsents.append(record)
        return .success(record)
    }
}