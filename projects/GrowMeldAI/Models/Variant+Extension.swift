// Variant+Validation.swift
import Foundation

extension Variant {
    /// Validates variant allocation percentage is within valid range
    public func validateAllocation() -> Result<Void, DomainError> {
        if allocationPercentage < 0 || allocationPercentage > 100 {
            return .failure(.invalidExperiment(violations: ["Variant allocation must be between 0 and 100"]))
        }
        return .success(())
    }
}