struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()  // No accessibility label
            
            Text("Standort wird ermittelt...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Standort wird ermittelt")
    }
}