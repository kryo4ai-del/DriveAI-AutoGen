// ExperimentValidation.swift
import Foundation

/// Validates experiment configuration and business rules
public struct ExperimentValidation {

    /// Validates experiment allocation percentages sum to 100%
    public static func validateAllocationPercentages(_ variants: [Variant]) -> Result<Void, DomainError> {
        let total = variants.reduce(0.0) { $0 + $1.allocationPercentage }
        let tolerance = 0.0001 // Floating point tolerance

        if abs(total - 100.0) > tolerance {
            return .failure(.allocationMismatch(expected: 100.0, actual: total))
        }
        return .success(())
    }

    /// Validates experiment date range
    public static func validateDateRange(start: Date, end: Date?) -> Result<Void, DomainError> {
        guard let end = end else { return .success(()) }
        if start >= end {
            return .failure(.dateRangeInvalid(start: start, end: end))
        }
        return .success(())
    }

    /// Validates experiment has at least one variant
    public static func validateHasVariants(_ variants: [Variant]) -> Result<Void, DomainError> {
        guard !variants.isEmpty else {
            return .failure(.invalidExperiment(violations: ["Experiment must have at least one variant"]))
        }
        return .success(())
    }

    /// Validates experiment status transitions
    public static func validateStatusTransition(from current: ExperimentStatus, to new: ExperimentStatus) -> Result<Void, DomainError> {
        switch (current, new) {
        case (.draft, .active), (.draft, .draft):
            return .success(())
        case (.active, .paused), (.active, .completed):
            return .success(())
        case (.paused, .active), (.paused, .completed):
            return .success(())
        case (.completed, _):
            return .failure(.invalidExperiment(violations: ["Cannot modify completed experiment"]))
        default:
            return .failure(.invalidExperiment(violations: ["Invalid status transition from \(current) to \(new)"]))
        }
    }

    /// Validates experiment configuration
    public static func validateExperiment(_ experiment: Experiment) -> Result<Experiment, DomainError> {
        var violations: [String] = []

        // Validate variants
        let variantValidation = validateAllocationPercentages(experiment.variants)
        if case .failure(let error) = variantValidation {
            violations.append(error.localizedDescription)
        }

        let hasVariants = validateHasVariants(experiment.variants)
        if case .failure(let error) = hasVariants {
            violations.append(error.localizedDescription)
        }

        // Validate dates
        let dateValidation = validateDateRange(start: experiment.startDate, end: experiment.endDate)
        if case .failure(let error) = dateValidation {
            violations.append(error.localizedDescription)
        }

        if !violations.isEmpty {
            return .failure(.invalidExperiment(violations: violations))
        }

        return .success(experiment)
    }
}