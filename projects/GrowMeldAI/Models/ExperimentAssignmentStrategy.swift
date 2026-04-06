// Services/ABTesting/Core/ExperimentAssignmentStrategy.swift

import Foundation
import CryptoKit

protocol ExperimentAssignmentStrategy: Sendable {
    func assignVariant(
        userId: String,
        experiment: Experiment
    ) -> Variant
}

// MARK: - Deterministic Hash-Based Strategy (MVP)

final class DeterministicAssignmentStrategy: ExperimentAssignmentStrategy {
    private let seed: String
    
    init(seed: String = "DriveAI") {
        self.seed = seed
    }
    
    func assignVariant(userId: String, experiment: Experiment) -> Variant {
        let hashInput = "\(userId):\(experiment.id):\(seed)"
        let hash = hashUserId(hashInput)
        
        return weightedVariantSelection(
            normalizedHash: hash,
            variants: experiment.variants
        )
    }
    
    private func hashUserId(_ input: String) -> Double {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        
        let hashBytes = digest.withUnsafeBytes { bytes in
            Array(bytes.prefix(8))
        }
        
        let hashValue = hashBytes.reduce(0) { acc, byte in
            (acc << 8) | UInt64(byte)
        }
        
        return Double(hashValue) / Double(UInt64.max)
    }
    
    private func weightedVariantSelection(
        normalizedHash: Double,
        variants: [Variant]
    ) -> Variant {
        var cumulative: Double = 0
        
        for variant in variants {
            cumulative += variant.weight
            if normalizedHash < cumulative {
                return variant
            }
        }
        
        // Fallback to last variant (safety)
        return variants.last ?? variants[0]
    }
}

// MARK: - Mock Strategy (Testing)

final class MockAssignmentStrategy: ExperimentAssignmentStrategy {
    var mockVariant: Variant?
    
    func assignVariant(userId: String, experiment: Experiment) -> Variant {
        mockVariant ?? experiment.variants.first ?? Variant(id: "default", weight: 1.0)
    }
}