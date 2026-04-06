// Services/SyncStatusService.swift
import Combine
import Foundation

@MainActor
class SyncStatusService: ObservableObject {
    @Published var isOnline: Bool = true
    @Published var pendingChanges: Int = 0
    @Published var lastSyncTime: Date?
    @Published var syncMessage: String = ""
    
    private let firestoreService: FirestoreService
    private let offlineQueue: OfflineQueueManager
    private var cancellables = Set<AnyCancellable>()
    
    init(
        firestoreService: FirestoreService,
        offlineQueue: OfflineQueueManager
    ) {
        self.firestoreService = firestoreService
        self.offlineQueue = offlineQueue
        setupBindings()
    }
    
    private func setupBindings() {
        // Monitor Firestore connection state
        firestoreService.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isOnline = isConnected
                self?.updateSyncMessage()
            }
            .store(in: &cancellables)
        
        // Monitor offline queue size
        offlineQueue.pendingChangesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.pendingChanges = count
                self?.updateSyncMessage()
            }
            .store(in: &cancellables)
        
        // Monitor last sync timestamp
        offlineQueue.lastSyncPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?.lastSyncTime = date
            }
            .store(in: &cancellables)
    }
    
    private func updateSyncMessage() {
        if !isOnline {
            syncMessage = "Offline – Änderungen werden synchronisiert"
        } else if pendingChanges > 0 {
            syncMessage = "Synchronisierung läuft..."
        } else {
            syncMessage = "Synchronisiert"
        }
    }
}