// ✅ GOOD - Focus reset on navigation
struct OnboardingCoordinator: View {
    @StateObject var viewModel: OnboardingViewModel
    @AccessibilityFocusState var focusedField: FocusableField?
    
    enum FocusableField: Hashable {
        case welcomeTitle
        case cameraButton
        case datePickerLabel
    }
    
    var body: some View {
        ZStack {
            switch viewModel.currentState {
            case .welcome:
                WelcomeView(viewModel: viewModel, focusedField: $focusedField)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.focusedField = .welcomeTitle
                        }
                    }
                
            case .cameraPermission:
                CameraPermissionView(viewModel: viewModel, focusedField: $focusedField)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.focusedField = .cameraButton
                        }
                    }
                    
            case .examDate:
                ExamDatePickerView(viewModel: viewModel, focusedField: $focusedField)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.focusedField = .datePickerLabel
                        }
                    }
                    
            case .complete:
                CompletionView(viewModel: viewModel)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Onboarding Complete")
            }
        }
        .onChange(of: viewModel.currentState) { oldValue, newValue in
            // Announce state transition
            UIAccessibility.post(notification: .announcement, argument: "Page changed to \(newValue.displayName)")
        }
    }
}

// In each view:
struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @AccessibilityFocusState var focusedField: FocusableField?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to DriveAI")
                .font(.title)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($focusedField, equals: .welcomeTitle)
                .focusable()
            
            Button("Continue") {
                viewModel.advance(to: .cameraPermission)
            }
            .accessibilityFocus($focusedField, equals: .cameraButton)
        }
    }
}