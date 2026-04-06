extension FirestoreService {
    func userStatsPublisher() -> AnyPublisher<UserStats, Never> {
        let retrySubject = PassthroughSubject<UserStats, Never>()
        var listenerRef: ListenerRegistration?
        var retryAttempt = 0
        let maxRetries = 3
        
        func attachListener() {
            listenerRef = db.collection("users")
                .document(Auth.auth().currentUser?.uid ?? "")
                .addSnapshotListener { [weak self] snapshot, error in
                    if let error = error {
                        // 1. Check if recoverable (not auth error)
                        let isRecoverable = (error as NSError).code != 1
                        
                        if isRecoverable && retryAttempt < maxRetries {
                            retryAttempt += 1
                            let delaySeconds = pow(2.0, Double(retryAttempt))
                            print("⚠️ Listener failed, retry #\(retryAttempt) in \(delaySeconds)s")
                            
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + delaySeconds
                            ) {
                                attachListener()
                            }
                        } else {
                            // 2. Emit error state for UI to show warning
                            self?.listenerErrorSubject.send(
                                "Statistiken nicht aktuell – versuche zu synchronisieren"
                            )
                        }
                    } else if let data = snapshot?.data() {
                        retryAttempt = 0 // Reset on success
                        let stats = try? UserStats.from(data)
                        if let stats = stats {
                            retrySubject.send(stats)
                        }
                    }
                }
        }
        
        attachListener()
        
        return retrySubject
            .eraseToAnyPublisher()
    }
    
    var listenerErrorSubject = PassthroughSubject<String, Never>()
}

// IN HOMEVIEWMODEL:
@Published var connectionWarning: String?

func loadDashboard() {
    firestoreService.userStatsPublisher()
        .receive(on: DispatchQueue.main)
        .sink { stats in
            self.viewState = .content(HomeContentState(...))
        }
        .store(in: &cancellables)
    
    // SURFACE ERROR IN UI
    firestoreService.listenerErrorSubject
        .receive(on: DispatchQueue.main)
        .assign(to: &$connectionWarning)
}

// IN HOMEVIEW:
if let warning = viewModel.connectionWarning {
    SyncStatusIndicator(
        message: warning,
        icon: "exclamationmark.triangle"
    )
}