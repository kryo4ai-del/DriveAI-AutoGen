@MainActor
protocol PassProbabilityValidatorProtocol: Sendable {
    func validate(config: ReadinessAlgorithmConfig) throws
}

@MainActor
final class PassProbabilityValidator: PassProbabilityValidatorProtocol {
    func validate(config: ReadinessAlgorithmConfig) throws {
        // Ensure formula produces sensible outputs
        let testScores = [0.0, 0.5, 0.75, 0.95, 1.0]
        var previousProb: Double = 0
        
        for score in testScores {
            let normalized = score
            let exponent = config.passLogisticSlope * (normalized - config.passLogisticIntercept)
            let prob = 1.0 / (1.0 + exp(-exponent))
            
            // Verify monotonic increase
            if prob < previousProb {
                throw ReadinessError(
                    message: "Algorithm produces non-monotonic probabilities",
                    code: "EA_VALIDATION_FAIL"
                )
            }
            previousProb = prob
        }
    }
}