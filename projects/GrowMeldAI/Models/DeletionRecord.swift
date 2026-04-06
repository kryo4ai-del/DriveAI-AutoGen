struct DeletionRecord {
    let id: UUID
    let originalRecordID: UUID
    let deletionDate: Date
    let deletionReason: DeletionReason
    let requestedBy: DeletionRequestor  // ✅ NEW
    let verificationMethod: VerificationMethod?  // ✅ NEW
    let recipientsNotified: [String]  // ✅ NEW
    let willAutoExpireOn: Date  // ✅ NEW (3 years from deletion)
}