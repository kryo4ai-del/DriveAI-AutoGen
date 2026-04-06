// Features/KIIdentifikation/Presentation/State/RecognitionState.swift
enum RecognitionState: Equatable {
    case idle
    case requestingPermission
    case scanning
    case processing(confidence: Float)
    case recognized(recognition: TrafficSignRecognition)
    case lowConfidence(suggestion: String)
    case error(message: String)
    case complete
    
    var isTerminal: Bool {
        switch self {
        case .recognized, .error, .complete:
            return true
        default:
            return false
        }
    }
    
    var displayText: String {
        switch self {
        case .idle:
            return "Bereit zum Scannen"
        case .requestingPermission:
            return "Kamera-Zugriff wird angefordert..."
        case .scanning:
            return "Zeichen wird gescannt..."
        case .processing(let conf):
            return "Verarbeitung... \(Int(conf * 100))%"
        case .recognized(let rec):
            return "✓ \(rec.sign.germanName)"
        case .lowConfidence(let msg):
            return msg
        case .error(let msg):
            return "Fehler: \(msg)"
        case .complete:
            return "Abgeschlossen"
        }
    }
}
