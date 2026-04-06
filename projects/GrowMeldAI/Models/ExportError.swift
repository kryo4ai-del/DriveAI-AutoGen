enum ExportError: LocalizedError {
    case encodingFailed
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Datenexport konnte nicht erstellt werden"
        case .invalidData:
            return "Ungültige Benutzerdaten"
        }
    }
}

func prepareDataExport(
    userId: UUID,
    userProfile: UserProfileData
) throws -> ExportedDataPackage {
    guard !userProfile.displayName.isEmpty else {
        throw ExportError.invalidData
    }
    
    let package = ExportedDataPackage(
        userId: userId,
        exportDate: Date(),
        examDate: userProfile.examDate,
        displayName: userProfile.displayName,
        totalQuestionsAnswered: userProfile.totalQuestionsAnswered,
        totalCorrect: userProfile.totalCorrect,
        consentHistory: consentManager.consentHistory,
        auditTrail: auditLog.entries
    )
    
    auditLog.log(
        eventType: "data_export_prepared",
        metadata: ["userId": userId.uuidString, "status": "success"],
        userConfirmed: true
    )
    
    return package
}

func generateJSON(package: ExportedDataPackage) throws -> Data {
    return try encoder.encode(package)
}