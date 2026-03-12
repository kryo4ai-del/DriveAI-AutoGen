extension AppNavigationView {
      private var initialView: some View {
          onboardingViewModel.isCompleted 
              ? AnyView(DashboardView(viewModel: DashboardViewModel())) 
              : AnyView(OnboardingView(viewModel: onboardingViewModel).navigationTitle("Welcome"))
      }

      var body: some View {
          NavigationStack {
              initialView
          }
      }
  }