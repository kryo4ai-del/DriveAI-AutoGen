enum PrivacyIncident {
    case encryptionKeyLost
    case auditLogCorrupted
    case unauthorizedDataAccess
    
    var userNotification: String {
        // DSGVO requires notifying users of breaches within 72 hours
    }
}