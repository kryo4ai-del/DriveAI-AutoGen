struct ReadinessAlgorithmConfig: Codable, Sendable {
    let weakAreaThreshold: Double = 0.70
    let passThreshold: Double = 0.75
    let minAttemptsForConfidence: Int = 3
    let passLogisticSlope: Double = 2.5  // ← INCREASED (steeper)
    let passLogisticIntercept: Double = 0.5
}