enum BackupError: LocalizedError {
    case diskSpaceInsufficient(required: UInt64, available: UInt64)
    
    var errorDescription: String? {
        switch self {
        case .diskSpaceInsufficient:
            return NSLocalizedString(
                "backup.error.insufficientSpace",
                comment: "User device doesn't have enough free space"
            )
        }
    }
}