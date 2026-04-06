// ✅ Models/CameraOnboarding/LicenseCaptureState.swift
import Foundation

enum LicenseCaptureState: Equatable, Hashable {
    case initial
    case permissionNeeded
    case capturing
    case preview(UIImage)
    case confirmed(CapturedLicenseImage)
    case error(LicenseCaptureError)
    
    var displayName: String {
        switch self {
        case .initial: return "Vorbereitung"
        case .permissionNeeded: return "Berechtigung erforderlich"
        case .capturing: return "Aufnahme läuft..."
        case .preview: return "Vorschau"
        case .confirmed: return "Bestätigt"
        case .error(let err): return "Fehler: \(err.localizedDescription)"
        }
    }
}

// ✅ Models/CameraOnboarding/LicenseCaptureError.swift

// ✅ Models/CameraOnboarding/CameraQualityMetrics.swift
struct CameraQualityMetrics: Codable, Equatable, Sendable {
    let brightness: Float   // 0.0-1.0
    let contrast: Float     // 0.0-1.0
    let focus: Float        // 0.0-1.0
    let alignment: Float    // 0.0-1.0
    
    var qualityScore: Float {
        // Weighted: focus(40%) + alignment(30%) + brightness(20%) + contrast(10%)
        (focus * 0.4) + (alignment * 0.3) + (brightness * 0.2) + (contrast * 0.1)
    }
    
    var isAcceptable: Bool {
        qualityScore >= 0.65
    }
    
    var feedback: String {
        let score = qualityScore
        switch score {
        case 0.85...: return "✅ Ausgezeichnet"
        case 0.70..<0.85: return "✅ Gut"
        case 0.65..<0.70: return "⚠️ Akzeptabel"
        default: return "❌ Zu niedrig"
        }
    }
}

// ✅ Models/CameraOnboarding/CapturedLicenseImage.swift

struct CapturedLicenseMetadata: Sendable, Equatable, Codable {
    let qualityMetrics: CameraQualityMetrics
    let fileSizeBytes: Int
    let compressionQuality: Float
    let imageHash: String  // SHA-256 for integrity
    
    enum CodingKeys: String, CodingKey {
        case qualityMetrics, fileSizeBytes, compressionQuality, imageHash
    }
}