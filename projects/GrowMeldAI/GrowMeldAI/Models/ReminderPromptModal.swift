struct ReminderPromptModal: View {
    @ObservedObject var viewModel: ReminderViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedButton: FocusedButton?
    
    enum FocusedButton {
        case decline
        case accept
    }
    
    var body: some View {
        if let trigger = viewModel.pendingTrigger {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                        .accessibilityLabel(Text("Benachrichtigung"))
                    
                    Text(titleFor(trigger: trigger))
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(descriptionFor(trigger: trigger))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .accessibilityAddTraits([.summaryElement])
                }
                .multilineTextAlignment(.center)
                .accessibilityElement(children: .combine)
                
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Text("Nicht jetzt")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .focused($focusedButton, equals: .decline)
                    .accessibilityLabel(Text("Nicht jetzt"))
                    .accessibilityHint(Text("Erinnerung ablehnen"))
                    .frame(minHeight: 44)  // Touch target
                    
                    Button(action: {
                        Task {
                            try await viewModel.acceptReminder()
                            dismiss()
                        }
                    }) {
                        Text("Erinnere mich")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .focused($focusedButton, equals: .accept)
                    .accessibilityLabel(Text("Erinnere mich"))
                    .accessibilityHint(Text("Erinnerung akzeptieren"))
                    .frame(minHeight: 44)  // Touch target
                    // Default focus on positive action
                    .onAppear {
                        focusedButton = .accept
                    }
                }
                .accessibilityElement(children: .contain)
            }
            .padding()
            .background(.background)
            .cornerRadius(12)
            .padding()
            .accessibilityElement(children: .contain)
            // Trap focus within modal (iOS 16.1+)
            .accessibilityRespondsToUserInteraction()
        }
    }
}