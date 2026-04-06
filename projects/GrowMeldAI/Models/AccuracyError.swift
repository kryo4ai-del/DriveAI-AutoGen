struct Accuracy {
    let percentage: Double
    
    init?(_ percentage: Double) {
        guard percentage >= 0, percentage <= 100 else {
            return nil
        }
        self.percentage = percentage
    }
}

// ✅ EXPLICIT VALIDATION
extension Accuracy {
    init?(correct: Int, total: Int) {
        // All invalid conditions in one guard
        guard total > 0, correct >= 0, correct <= total else {
            return nil
        }
        let pct = (Double(correct) / Double(total)) * 100
        self.init(pct)  // Now guaranteed to succeed
    }
}

// Even better: throw for better diagnostics
enum AccuracyError: LocalizedError {
    case invalidTotal
    case negativeCorrect
    case correctExceedsTotal
    
    var errorDescription: String? {
        switch self {
        case .invalidTotal:
            return "Gesamtzahl muss größer als 0 sein"
        case .negativeCorrect:
            return "Korrekte Antworten können nicht negativ sein"
        case .correctExceedsTotal:
            return "Korrekte Antworten können nicht größer als die Gesamtzahl sein"
        }
    }
}

extension Accuracy {
    init(_ correct: Int, _ total: Int) throws {
        guard total > 0 else { throw AccuracyError.invalidTotal }
        guard correct >= 0 else { throw AccuracyError.negativeCorrect }
        guard correct <= total else { throw AccuracyError.correctExceedsTotal }
        
        let pct = (Double(correct) / Double(total)) * 100
        guard let accuracy = Accuracy(pct) else {
            // This should never happen now, but catch programming errors
            throw AccuracyError.invalidTotal
        }
        self = accuracy
    }
}