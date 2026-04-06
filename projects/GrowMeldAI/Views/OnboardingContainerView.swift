// Views/Onboarding/OnboardingContainerView.swift
struct OnboardingContainerView: View {
    @StateObject var flowVM = OnboardingFlowViewModel()
    
    var body: some View {
        NavigationStack(path: $flowVM.navigationPath) {
            // Navigation destination is derived from state
            switch flowVM.currentState {
            case .welcome:
                WelcomeView(viewModel: flowVM)
                    .navigationDestination(for: OnboardingFlowViewModel.Step.self) { step in
                        destinationView(for: step)
                    }
            // ... other cases
            }
        }
    }
    
    @ViewBuilder
    func destinationView(for step: OnboardingFlowViewModel.Step) -> some View {
        switch step {
        case .welcome:
            EmptyView() // Should not be reached
        case .permissionRequest:
            PermissionRequestView(viewModel: flowVM)
        case .profileInput:
            ProfileInputView(viewModel: flowVM)
        // ...
        }
    }
}