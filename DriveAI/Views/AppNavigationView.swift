@main
struct DriveAIApp: App {
    var body: some Scene {
        WindowGroup {
            AppNavigationView()
        }
    }
}

struct AppNavigationView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            if onboardingViewModel.isCompleted {
                DashboardView(viewModel: DashboardViewModel())
            } else {
                OnboardingView(viewModel: onboardingViewModel)
                    .navigationTitle("Welcome")
            }
        }
    }
}