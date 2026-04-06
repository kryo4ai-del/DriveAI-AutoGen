import Foundation
import UIKit

enum LicenseCaptureError: Error, LocalizedError, Equatable, Hashable {
    case permissionDenied
    case captureSessionFailed(String)
    case imageProcessingFailed(String)
    case qualityTooLow(Float)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Kamerazugriff verweigert"
        case .captureSessionFailed(let reason):
            return "Aufnahme fehlgeschlagen: \(reason)"
        case .imageProcessingFailed(let reason):
            return "Bildverarbeitung fehlgeschlagen: \(reason)"
        case .qualityTooLow(let score):
            return "Bildqualität zu niedrig: \(String(format: "%.0f%%", score * 100))"
        }
    }
}

struct CameraQualityMetrics: Codable, Equatable, Sendable {
    let brightness: Float
    let contrast: Float
    let focus: Float
    let alignment: Float

    var qualityScore: Float {
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

struct CapturedLicenseMetadata: Sendable, Equatable, Codable {
    let qualityMetrics: CameraQualityMetrics
    let fileSizeBytes: Int
    let compressionQuality: Float
    let imageHash: String

    enum CodingKeys: String, CodingKey {
        case qualityMetrics, fileSizeBytes, compressionQuality, imageHash
    }
}

struct CapturedLicenseImage: Equatable, Hashable {
    let image: UIImage
    let metadata: CapturedLicenseMetadata

    static func == (lhs: Models.CapturedLicenseImage, rhs: Models.CapturedLicenseImage) -> Bool {
        lhs.metadata == rhs.metadata
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(metadata.imageHash)
    }
}

enum LicenseCaptureState: Equatable, Hashable {
    case initial
    case permissionNeeded
    case capturing
    case preview(UIImage)
    case confirmed(Models.CapturedLicenseImage)
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

    static func == (lhs: Models.LicenseCaptureState, rhs: Models.LicenseCaptureState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case (.permissionNeeded, .permissionNeeded): return true
        case (.capturing, .capturing): return true
        case (.preview, .preview): return true
        case (.confirmed(let a), .confirmed(let b)): return a == b
        case (.error(let a), .error(let b)): return a == b
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .initial: hasher.combine(0)
        case .permissionNeeded: hasher.combine(1)
        case .capturing: hasher.combine(2)
        case .preview: hasher.combine(3)
        case .confirmed(let img): hasher.combine(4); hasher.combine(img)
        case .error(let err): hasher.combine(5); hasher.combine(err)
        }
    }
}

private enum Models {
    typealias CapturedLicenseImage = GrowMeldAI.CapturedLicenseImage
    typealias LicenseCaptureState = GrowMeldAI.LicenseCaptureState
}