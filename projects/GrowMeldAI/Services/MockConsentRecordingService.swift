import Foundation
class MockConsentRecordingService: ConsentRecordingService {
    var recordedConsents: [ConsentRecord] = []
    
    override func recordConsent(
        birthDate: Date,
        region: ComplianceRegion,
        action: UserAction
    ) -> Result<ConsentRecord, ConsentError> {
        let record = ConsentRecord(
            id: UUID(),
            birthYear: Calendar.current.component(.year, from: birthDate),
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