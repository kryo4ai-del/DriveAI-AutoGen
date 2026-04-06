// Features/KIIdentifikation/Infrastructure/MLModels/ConfidenceSmoother.swift

struct ConfidenceSmoother {
    private let alpha: Float = 0.3 // EMA smoothing factor (adjustable)
    private var smoothedValue: Float = 0
    private var sampleCount = 0
    
    /// Exponential moving average smoothing
    mutating func smooth(_ rawConfidence: Float) -> Float {
        if sampleCount == 0 {
            smoothedValue = rawConfidence
        } else {
            smoothedValue = (alpha * rawConfidence) + ((1 - alpha) * smoothedValue)
        }
        sampleCount += 1
        return smoothedValue
    }
    
    mutating func reset() {
        smoothedValue = 0
        sampleCount = 0
    }
    
    var sampleCount: Int { sampleCount }
}