struct SplashView: View {
    @Environment(AuthState.self) var authState
    @State private var viewModel: AuthViewModel?
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Routing based on auth state
            Group {
                switch authState.status {
                case .loading:
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Wird geladen...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                case .unauthenticated:
                    if let vm = viewModel {
                        AuthNavigationStack(viewModel: vm)
                    } else {
                        ProgressView()  // Brief transition
                    }
                    
                case .authenticated:
                    DashboardView()
                    
                case .error(let message):
                    ErrorStateView(
                        message: message,
                        onRetry: { await initAuth() }
                    )
                }
            }
            .transition(.opacity)
        }
        .task {
            await initAuth()
        }
    }
    
    @MainActor
    private func initAuth() async {
        authState.status = .loading
        
        let errorReporter = FirebaseCrashReportingService.shared
        let authService = AuthService(errorReporter: errorReporter)
        
        let vm = AuthViewModel(
            authService: authService,
            authState: authState
        )
        self.viewModel = vm
        
        await authState.checkAuthStatus(authService: authService)
    }
}

// New: Separate navigation for auth screens