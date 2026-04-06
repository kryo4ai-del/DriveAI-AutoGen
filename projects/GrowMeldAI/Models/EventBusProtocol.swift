import Foundation
import Combine

protocol EventBusProtocol: AnyObject {
    func publish(_ event: DriveAIEvent) -> AnyPublisher<Void, EventBusError>
    func subscribe() -> AnyPublisher<DriveAIEvent, Never>
}

enum EventBusError: LocalizedError {
    case publishFailed(String)
    case notInitialized

    var errorDescription: String? {
        switch self {
        case .publishFailed(let msg):
            return "Event publication failed: \(msg)"
        case .notInitialized:
            return "EventBus not initialized"
        }
    }
}

final class EventBus: EventBusProtocol {
    private let eventSubject = PassthroughSubject<DriveAIEvent, Never>()
    private let lock = NSLock()

    func publish(_ event: DriveAIEvent) -> AnyPublisher<Void, EventBusError> {
        lock.lock()
        defer { lock.unlock() }
        #if DEBUG
        print("📡 Event published: \(event)")
        #endif
        eventSubject.send(event)
        return Just(()).setFailureType(to: EventBusError.self).eraseToAnyPublisher()
    }

    func subscribe() -> AnyPublisher<DriveAIEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}