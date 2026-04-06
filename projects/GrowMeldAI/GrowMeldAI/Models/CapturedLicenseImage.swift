import Foundation

/// Metadata for a captured license image
struct CapturedLicenseImage: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let compressionQuality: Float
    let qualityMetrics: CameraQualityMetrics
    let fileSize: Int
    let localPath: String?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        compressionQuality: Float = 0.8,
        qualityMetrics: CameraQualityMetrics,
        fileSize: Int,
        localPath: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.compressionQuality = compressionQuality
        self.qualityMetrics = qualityMetrics
        self.fileSize = fileSize
        self.localPath = localPath
    }
}

/// Quality metrics for image validation
struct CameraQualityMetrics: Codable {
    let brightness: Float  // 0.0 - 1.0
    let contrast: Float    // 0.0 - 1.0
    let focus: Float       // 0.0 - 1.0 (via blur detection)
    let alignment: Float   // 0.0 - 1.0 (document edges detected)
    
    var qualityScore: Float {
        (brightness + contrast + focus + alignment) / 4.0
    }
    
    var isAcceptable: Bool {
        qualityScore >= 0.65
    }
    
    var feedbackMessage: String {
        switch qualityScore {
        case 0.85...:
            return "✅ Perfekt! Foto ist bereit."
        case 0.70..<0.85:
            return "⚠️ Gut genug. Für bessere Erkennung: besseres Licht, flacher Winkel."
        case 0.65..<0.70:
            return "⚠️ Akzeptabel. Empfohlen: Licht, Fokus überprüfen."
        default:
            return "❌ Zu niedrig. Versuche: besseres Licht, flacher Winkel, scharfer Fokus."
        }
    }
}