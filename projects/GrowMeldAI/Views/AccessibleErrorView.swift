// ❌ WRONG
Text(viewModel.errorMessage)
    .font(.body)

// ✅ CORRECT
Text(viewModel.errorMessage)
    .font(.body)
    .lineLimit(nil)           // Allow wrapping
    .fixedSize(horizontal: false, vertical: true)  // Respect size
    .accessibilityAddTraits(.isButton)  // Semantic
    
// ✅ BETTER: Use custom style
struct AccessibleErrorView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .accessibility(hidden: true)
                
                Text(message)
                    .font(.body)
                    .lineLimit(nil)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                }
                .accessibilityLabel("Dismiss error")
            }
            .padding()
            .background(Color(.systemRed).opacity(0.1))
            .cornerRadius(8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isAlert)
    }
}