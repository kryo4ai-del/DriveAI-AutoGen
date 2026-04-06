struct ErrorStateView: View {
    let error: LocationError
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundColor(.red)
                .accessibilityHidden(true)  // Icon is decorative
            
            Text("Fehler beim Laden")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.gray)  // Improved contrast
                .multilineTextAlignment(.center)
            
            Button(action: onRetry) {
                Text("Erneut versuchen")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Fehler")
        .accessibilityLiveRegion(.assertive)  // CRITICAL: Announce immediately
    }
}