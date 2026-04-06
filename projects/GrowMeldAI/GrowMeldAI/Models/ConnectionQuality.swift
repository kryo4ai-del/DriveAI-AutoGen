// Services/Firebase/FirestoreHealthMonitor.swift
import Combine
import Foundation
import Network

actor FirestoreHealthMonitor {
    @Published private(set) var isOnline: Bool = true
    @Published private(set) var connectionQuality: ConnectionQuality = .good

    enum ConnectionQuality {
        case good
        case poor
        case offline
    }

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    private var lastSuccessfulOperation: Date = Date()

    nonisolated var isOnlinePublisher: AnyPublisher<Bool, Never> {
        $isOnline
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "com.driveai.firestore.health")
        monitor.pathUpdateHandler = { [weak self] path in
            Task { await self?.handlePathUpdate(path) }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    private func handlePathUpdate(_ path: NWPath) {
        let isOnline = path.status == .satisfied
        let quality: ConnectionQuality

        if path.usesInterfaceType(.wifi) {
            quality = .good
        } else if path.usesInterfaceType(.cellular) {
            quality = path.isExpensive ? .poor : .good
        } else {
            quality = .offline
        }

        Task {
            await updateStatus(isOnline: isOnline, quality: quality)
        }
    }

    private func updateStatus(isOnline: Bool, quality: ConnectionQuality) {
        self.isOnline = isOnline
        self.connectionQuality = quality

        if isOnline {
            lastSuccessfulOperation = Date()
        }
    }

    func recordSuccess() {
        lastSuccessfulOperation = Date()
    }

    func shouldRetry(attempt: Int) -> Bool {
        guard isOnline else { return false }

        let backoff = min(pow(2.0, Double(attempt)), 60.0) // Cap at 60 seconds
        let timeSinceLastSuccess = Date().timeIntervalSince(lastSuccessfulOperation)

        return timeSinceLastSuccess > backoff
    }
}