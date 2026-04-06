// Services/Firestore/ResilientListenerManager.swift
import Combine
import Foundation

@MainActor
class ResilientListenerManager {
    private var activeListeners: [String: Any] = [:]
    private var listenerStates: [String: ListenerState] = [:]

    enum ListenerState {
        case attached
        case reconnecting(attempt: Int)
        case failed(error: Error)
    }

    func attachListener<T: Decodable>(
        id: String,
        path: String,
        decoder: @escaping ([String: Any]) -> T?,
        maxRetries: Int = 3
    ) -> AnyPublisher<T, Never> {
        let subject = PassthroughSubject<T, Never>()

        func attach(retryCount: Int = 0) {
            listenerStates[id] = .attached

            // Stub listener token using a UUID as a placeholder
            // Replace the body below with real Firestore listener when SDK is available
            let listenerToken = FirestoreListenerToken(onRemove: {})
            activeListeners[id] = listenerToken

            // NOTE: When FirebaseFirestore is available, replace this block with:
            // let listener = Firestore.firestore()
            //     .document(path)
            //     .addSnapshotListener { [weak self] snapshot, error in ... }
            // activeListeners[id] = listener

            _ = path // suppress unused warning
            _ = decoder
        }

        attach()

        return subject.eraseToAnyPublisher()
    }

    private func handleListenerError(
        id: String,
        error: Error,
        retryCount: Int,
        maxRetries: Int,
        reattach: @escaping () -> Void
    ) {
        let nsError = error as NSError
        let isRecoverable = nsError.code != 1 // Not auth error

        guard isRecoverable && retryCount < maxRetries else {
            listenerStates[id] = .failed(error: error)
            return
        }

        listenerStates[id] = .reconnecting(attempt: retryCount + 1)
        let backoffDelay = pow(2.0, Double(retryCount))

        DispatchQueue.main.asyncAfter(deadline: .now() + backoffDelay) {
            reattach()
        }
    }

    func detachListener(id: String) {
        if let token = activeListeners[id] as? FirestoreListenerToken {
            token.remove()
        }
        activeListeners.removeValue(forKey: id)
        listenerStates.removeValue(forKey: id)
    }

    func listenerState(id: String) -> AnyPublisher<ListenerState, Never> {
        Just(listenerStates[id] ?? .attached)
            .eraseToAnyPublisher()
    }
}

// MARK: - Stub for ListenerRegistration (mirrors FirebaseFirestore.ListenerRegistration)
// Remove this when FirebaseFirestore SDK is properly linked.

final class FirestoreListenerToken {
    private let onRemoveHandler: () -> Void

    init(onRemove: @escaping () -> Void) {
        self.onRemoveHandler = onRemove
    }

    func remove() {
        onRemoveHandler()
    }
}