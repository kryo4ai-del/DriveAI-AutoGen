// ❌ INCOMPLETE:
// Error shown, but user can't open Settings from app

// ✅ ADD:
enum CameraError: LocalizedError {
    // ... existing cases ...
    
    var canRetry: Bool {
        switch self {
        case .sessionStartFailed, .captureFailed:
            return true
        default:
            return false
        }
    }
    
    var suggestedAction: CameraErrorAction? {
        switch self {
        case .permissionDenied:
            return .openSettings
        case .sessionStartFailed, .captureFailed:
            return .retry
        default:
            return nil
        }
    }
}

enum CameraErrorAction {
    case openSettings
    case retry
}