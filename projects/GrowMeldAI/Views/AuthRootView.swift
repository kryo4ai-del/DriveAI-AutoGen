import SwiftUI

struct AuthRootView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            ZStack {
                if showSignUp {
                    SignUpView()
                        .environmentObject(viewModel)
                } else {
                    SignInView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
}