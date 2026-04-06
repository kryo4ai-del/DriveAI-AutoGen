public struct DeterministicVariantAssigner {
    private let seed: UInt32
    
    /// Hash-based deterministic assignment
    public func assignVariant(
        userID: String,
        to variants: [Variant]
    ) -> Result<Variant, DomainError> {
        let hash = userID.hashValue
        let normalizedHash = abs(hash) % 100
        
        var cumulative = 0.0
        for variant in variants {
            cumulative += variant.allocationPercentage
            if Double(normalizedHash) < cumulative {
                return .success(variant)
            }
        }
        return .failure(.assignmentFailed(reason: "No variant matched allocation"))
    }
}