struct PermissionLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .accessibilityHidden(true)  // CRITICAL: Hide redundant "Loading"
            
            Text("Standort wird ermittelt...")
                .font(.body)
                .foregroundColor(.secondary)
                .accessibilityLabel("Standort wird ermittelt. Bitte warten.")
        }
        .accessibilityElement(children: .ignore)  // Combine into single element
        .accessibilityLabel("Standort wird ermittelt")
        .accessibilityLiveRegion(.polite)  // Announce when loading starts
    }
}