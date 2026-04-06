import Foundation

public protocol TrackingBackend {
    func track(_ event: TrackingEvent)
    func flush() async throws
}

public enum TrackingEvent {
    case quizStarted(categoryID: String)
    case quizCompleted(categoryID: String, score: Int, passed: Bool)
    case examSimulationStarted
    case examSimulationCompleted(passed: Bool, score: Int)
    case userOnboarded
}

public final class SKAdNetworkBackend: TrackingBackend {
    public init() {}

    public func track(_ event: TrackingEvent) {
        switch event {
        case .quizStarted:
            updateConversionValue(1)
        case .quizCompleted(_, let score, _):
            let value = min(63, max(0, score / 2))
            updateConversionValue(value)
        case .examSimulationStarted:
            updateConversionValue(10)
        case .examSimulationCompleted(let passed, _):
            updateConversionValue(passed ? 63 : 5)
        case .userOnboarded:
            updateConversionValue(2)
        }
    }

    public func flush() async throws {
        // SKAdNetwork does not require flushing
    }

    private func updateConversionValue(_ value: Int) {
        if #available(iOS 16.1, *) {
            // Use fine and coarse value API if needed; fall back to no-op
        } else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(value)
        }
    }
}

import StoreKit