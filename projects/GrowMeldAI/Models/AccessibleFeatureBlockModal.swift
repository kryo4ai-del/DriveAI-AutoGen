struct AccessibleFeatureBlockModal: View {
    @State private var focusedButton: FocusableButton? = .dismiss
    
    enum FocusableButton {
        case dismiss
        case upgrade
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Feature Limit Reached")
                .font(.headline)
            
            // ✅ Dismiss button first (logical Tab order)
            Button(action: { dismiss() }) {
                Text("Dismiss")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .focused($focusedButton, equals: .dismiss)
            
            // ✅ Primary CTA second
            Button(action: { navigateToPaywall() }) {
                Text("Upgrade to Premium")
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.white)
                    .background(Color.blue)
            }
            .focused($focusedButton, equals: .upgrade)
            .keyboardShortcut(.defaultAction)  // Return key triggers upgrade
        }
        .onAppear {
            // Set initial focus to dismiss (safer default)
            focusedButton = .dismiss
        }
    }
}