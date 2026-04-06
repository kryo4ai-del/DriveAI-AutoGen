// SKAdNetworkBackend.swift
import Foundation
import StoreKit

/// SKAdNetwork backend for privacy-preserving conversion tracking.
public final class SKAdNetworkBackend: TrackingBackend {
    public init() {}

    public func track(_ event: TrackingEvent) {
        // Convert TrackingEvent to SKAdNetwork event
        let skAdEvent: SKAdNetworkEvent

        switch event {
        case .quizStarted(let categoryID):
            skAdEvent = .startTutorial(categoryID: categoryID)
        case .quizCompleted(let categoryID, let score, _):
            skAdEvent = .completeTutorial(categoryID: categoryID, score: score)
        case .examSimulationStarted:
            skAdEvent = .startCheckout
        case .examSimulationCompleted(let passed, let score):
            skAdEvent = .purchase(success: passed, amount: score)
        case .userOnboarded:
            skAdEvent = .subscribe
        }

        SKAdNetwork.reportEvent(skAdEvent)
    }

    public func flush() async throws {
        // SKAdNetwork doesn't require flushing
    }
}

private enum SKAdNetworkEvent {
    case startTutorial(categoryID: String)
    case completeTutorial(categoryID: String, score: Int)
    case startCheckout
    case purchase(success: Bool, amount: Int)
    case subscribe

    var eventName: String {
        switch self {
        case .startTutorial: return "start_tutorial"
        case .completeTutorial: return "complete_tutorial"
        case .startCheckout: return "start_checkout"
        case .purchase: return "purchase"
        case .subscribe: return "subscribe"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .startTutorial(let categoryID):
            return ["category_id": categoryID]
        case .completeTutorial(let categoryID, let score):
            return ["category_id": categoryID, "score": score]
        case .purchase(let success, let amount):
            return ["success": success, "amount": amount]
        default:
            return [:]
        }
    }
}