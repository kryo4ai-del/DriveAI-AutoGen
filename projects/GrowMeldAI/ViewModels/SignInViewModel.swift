// Features/Auth/Application/ViewModels/SignInViewModel.swift

import Foundation

@MainActor
final class SignInViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPasswordVisible = false
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        email.contains("@") &&
        isValidEmail(email)
    }
    
    // MARK: - Private Properties
    
    private let authUseCase: AuthUseCase
    
    // MARK: - Initialization
    
    init(authUseCase: AuthUseCase = .shared) {
        self.authUseCase = authUseCase
    }
    
    // MARK: - Public Methods
    
    func signIn() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        
        do {
            _ = try await authUseCase.signIn(
                email: trimmedEmail,
                password: password
            )
            // AuthViewModel observes state change and handles navigation
        } catch let error as AuthError {
            errorMessage = error.userFriendlyMessage
        } catch {
            errorMessage = String(localized: "auth.error.unknown")
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}