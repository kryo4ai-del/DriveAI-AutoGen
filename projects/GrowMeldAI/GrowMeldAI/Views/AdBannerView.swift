struct AdBannerView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Anzeige") // Ad label
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { dismissAd() }) {
                    Image(systemName: "xmark.circle")
                        .accessibilityLabel("Anzeige schließen")
                        .accessibilityHint("Entfernt diese Anzeige")
                }
                .frame(width: 44, height: 44) // Minimum touch target
            }
            // Ad content here
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Anzeige")
        .accessibilityHint("Tippen zum Öffnen, oder schließen-Taste zum Verwerfen")
    }
}