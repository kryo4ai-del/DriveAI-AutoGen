import SwiftUI

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Text("Sign In")
    }
}

struct SignUpView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Text("Sign Up")
    }
}

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
}

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