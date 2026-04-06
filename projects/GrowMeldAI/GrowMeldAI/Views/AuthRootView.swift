// Features/Auth/Application/Views/Auth/AuthRootView.swift

struct AuthRootView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if showSignUp {
                    SignUpView(
                        viewModel: SignUpViewModel(),
                        showSignUp: $showSignUp
                    )
                } else {
                    SignInView(
                        viewModel: SignInViewModel(),
                        showSignUp: $showSignUp
                    )
                }
            }
            .environmentObject(viewModel)
        }
    }
}