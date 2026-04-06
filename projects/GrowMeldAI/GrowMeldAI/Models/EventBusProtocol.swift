import Foundation
import Combine

/// Central event dispatcher (thread-safe, non-blocking)
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

actor EventBus: EventBusProtocol {
    private let eventSubject = PassthroughSubject<DriveAIEvent, Never>()
    private var subscribers: [UUID: AnyCancellable] = [:]
    
    nonisolated func publish(_ event: DriveAIEvent) -> AnyPublisher<Void, EventBusError> {
        Future { [weak self] promise in
            Task {
                await self?._publish(event, promise: promise)
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func _publish(
        _ event: DriveAIEvent,
        promise: @escaping (Result<Void, EventBusError>) -> Void
    ) {
        #if DEBUG
        print("📡 Event published: \(event)")
        #endif
        
        eventSubject.send(event)
        promise(.success(()))
    }
    
    nonisolated func subscribe() -> AnyPublisher<DriveAIEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
}