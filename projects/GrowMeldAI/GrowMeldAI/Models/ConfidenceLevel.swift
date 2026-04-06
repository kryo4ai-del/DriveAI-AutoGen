enum ConfidenceLevel {
    case high      // ≥80%: Show result confidently
    case uncertain // 70-80%: Show with warning + verification prompt
    case low       // <70%: Don't show result, encourage retry
}

func determineConfidenceLevel(_ confidence: Float) -> ConfidenceLevel {
    switch confidence {
    case 0.80...:  return .high
    case 0.70..<0.80: return .uncertain
    default:       return .low
    }
}