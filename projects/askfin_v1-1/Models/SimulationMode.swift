import Foundation
import Combine

// MARK: - SimulationMode

enum SimulationMode: String, Codable, CaseIterable, Equatable {
    case realistic  // No feedback, timed — exam conditions
    case practice   // Future: with feedback (modelled, UI not yet implemented)
}

// NOTE: SimulationConfig is defined in SimulationConfig.swift.
// NOTE: ExamSimulation is defined in ExamSimulation.swift.
// NOTE: SimulationResult is defined in SimulationResult.swift.
// NOTE: FehlerpunkteCategory is defined in FehlerpunkteCategory.swift.