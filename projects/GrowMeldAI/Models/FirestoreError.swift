import Foundation
import Combine

enum FirestoreError: LocalizedError {
    case networkUnavailable
    case authenticationFailed
    case documentNotFound
    case decodingFailed(underlying: Error)
    case encodingFailed(underlying: Error)
    case quotaExceeded
    case permissionDenied
    case unknownError(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Netzwerk nicht verfügbar"
        case .authenticationFailed:
            return "Authentifizierung erforderlich"
        case .documentNotFound:
            return "Dokument nicht gefunden"
        case .decodingFailed:
            return "Daten konnten nicht verarbeitet werden"
        case .quotaExceeded:
            return "Kontingent überschritten. Bitte später versuchen"
        case .permissionDenied:
            return "Zugriff verweigert"
        case .unknownError:
            return "Ein Fehler ist aufgetreten"
        case .encodingFailed:
            return "Daten konnten nicht kodiert werden"
        }
    }
}

actor FirestoreHealthMonitor {
    private(set) var isOnline: Bool = true
    private(set) var connectionQuality: ConnectionQuality = .good
    
    enum ConnectionQuality {
        case good
        case poor
        case offline
    }
    
    private var reachability: NetworkReachability?
    private var lastSuccessfulOperation: Date = Date()
    
    private let isOnlineSubject = CurrentValueSubject<Bool, Never>(true)
    
    nonisolated var isOnlinePublisher: AnyPublisher<Bool, Never> {
        isOnlineSubject.eraseToAnyPublisher()
    }
    
    init() {
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        // Monitor network changes
        // Update isOnline accordingly
    }
    
    func recordSuccess() {
        lastSuccessfulOperation = Date()
    }
    
    func shouldRetry(attempt: Int) -> Bool {
        guard isOnline else { return false }
        let backoff = pow(2.0, Double(attempt)) // Exponential: 1s, 2s, 4s, 8s...
        return backoff < 60 // Cap at 60 seconds
    }
    
    func setOnline(_ online: Bool) {
        isOnline = online
        isOnlineSubject.send(online)
        connectionQuality = online ? .good : .offline
    }
}

@globalActor
actor FirestoreActor {
    static let shared = FirestoreActor()
}

// MARK: - Network Reachability Helper
protocol NetworkReachability {
    var isReachable: Bool { get }
    var publisher: AnyPublisher<Bool, Never> { get }
}