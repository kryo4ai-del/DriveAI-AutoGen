import Foundation

enum LicenseCaptureError: LocalizedError, Equatable {
    case permissionDenied
    case cameraNotAvailable
    case poorImageQuality(CameraQualityMetrics)
    case storageFailure(String)
    case processingFailed(String)
    case invalidImage
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Kamerazugriff erforderlich. Bitte in den Einstellungen aktivieren."
        case .cameraNotAvailable:
            return "Kamera nicht verfügbar. Gerät wird nicht unterstützt."
        case .poorImageQuality(let metrics):
            return metrics.feedbackMessage
        case .storageFailure(let reason):
            return "Fehler beim Speichern: \(reason)"
        case .processingFailed(let reason):
            return "Fehler bei der Verarbeitung: \(reason)"
        case .invalidImage:
            return "Ungültiges Bild. Bitte versuchen Sie es erneut."
        case .unknown(let reason):
            return "Unbekannter Fehler: \(reason)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Gehen Sie zu Einstellungen > DriveAI > Kamera und aktivieren Sie den Zugriff."
        case .poorImageQuality:
            return "Versuchen Sie es mit besserem Licht und flacherem Winkel erneut."
        case .storageFailure:
            return "Überprüfen Sie den Speicherplatz und versuchen Sie es erneut."
        default:
            return "Versuchen Sie es erneut."
        }
    }
}