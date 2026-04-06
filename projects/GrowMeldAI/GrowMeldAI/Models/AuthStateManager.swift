@MainActor
final class AuthStateManager: ObservableObject {
    @Published var authState: AuthViewModel.AuthState
    
    private let keychainService: KeychainService
    private let userDefaults: UserDefaults
    
    func persistAuthState(_ state: AuthViewModel.AuthState) {
        switch state {
        case .authenticated(let user):
            try? keychainService.save(user.id, forKey: "authUserID")
            userDefaults.set(user.examSchedule.examDate, forKey: "examDate")
        case .unauthenticated:
            keychainService.delete(forKey: "authUserID")
        default:
            break
        }
    }
}