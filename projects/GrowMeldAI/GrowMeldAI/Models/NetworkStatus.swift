enum NetworkStatus: Equatable {
    case connected(NetworkType)
    case disconnected
    case permissionDenied  // ✅ Add explicit state
    case unknown
}

private func updateState(_ path: NWPath) {
    // Check for permission denial (no connectivity, no unsatisfiable status)
    // This is harder to detect—consider adding diagnostic
    
    switch path.status {
    case .satisfied:
        state = .connected(...)
    case .unsatisfied, .unsatisfiable:
        state = .disconnected
    @unknown default:
        state = .unknown
    }
}