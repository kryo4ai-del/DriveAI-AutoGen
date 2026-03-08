func nextPage(completion: (() -> Void)? = nil) {
        guard currentPage < totalPages - 1 else { return }
        currentPage += 1
        completion?()
    }

// ---

// If your navigation logic is set up
NavigationLink(destination: ExamDateSetupView()) {
    // Button Code
}

// ---

@ViewBuilder
func buildPageView(for model: OnboardingScreenModel) -> some View {
    OnboardingPageView(screenModel: model)
}

// ---

func nextPage(completion: (() -> Void)? = nil) {
    guard currentPage < totalPages - 1 else { return }
    currentPage += 1
    completion?()
}

// ---

func skipOnboarding(to view: AnyView) {
    // Logic to navigate to the Exam Date Setup
}

// ---

private let screens: [OnboardingScreenModel] // Encapsulated access

// ---

NavigationLink(destination: ExamDateSetupView()) {
    Button("Next") {
        viewModel.nextPage()
    }
}

// ---

@ViewBuilder
private func buildPageView(for model: OnboardingScreenModel) -> some View {
    OnboardingPageView(screenModel: model)
}

// ---

let welcomeTitle = LocalizedStringKey("welcome_title") // Example

// ---

let welcomeTitle = LocalizedStringKey("welcome_title") // Example