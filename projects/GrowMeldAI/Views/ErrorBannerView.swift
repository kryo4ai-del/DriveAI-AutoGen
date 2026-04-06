// File: Views/ErrorBannerView.swift
struct ErrorBannerView: View {
    let error: ResilienceError
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(error.userMessage)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemRed).opacity(0.1))
        .cornerRadius(8)
        // ✅ For screen reader users, use accessibility-optimized message
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            accessibilityEnabled ? error.accessibilityMessage : error.userMessage
        )
    }
}