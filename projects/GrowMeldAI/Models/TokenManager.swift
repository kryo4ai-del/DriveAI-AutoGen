@MainActor
final class TokenManager {
    @Published var isTokenValid = true
    
    private var tokenRefreshTimer: Timer?
    
    func startTokenRefreshCycle() {
        tokenRefreshTimer = Timer.scheduledTimer(withTimeInterval: 55 * 60, repeats: true) { _ in
            Task {
                await self.refreshToken()
            }
        }
    }
    
    private func refreshToken() async {
        do {
            try await FirebaseAuth.Auth.auth().currentUser?.getIDTokenForcingRefresh(true)
        } catch {
            isTokenValid = false
            // Trigger re-login UI
        }
    }
    
    deinit {
        tokenRefreshTimer?.invalidate()
    }
}