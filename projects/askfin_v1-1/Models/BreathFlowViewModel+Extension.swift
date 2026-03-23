// BreathFlowTestHelpers.swift

extension BreathFlowViewModel {
    /// Test-only: directly invoke tick() to simulate timer firing.
    /// Requires @testable import.
    @MainActor
    func simulateTick(elapsedFraction: Double) {
        // Override progress directly for unit testing
        // This requires exposing a test seam — see §2.1 recommendation below
    }
}