struct LocationSelectionView: View {
    @StateObject var viewModel: LocationSelectionViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // ... header ...
            
            // Suggestions with minimum touch target
            if !viewModel.suggestions.isEmpty {
                List(viewModel.suggestions) { plz in
                    Button(action: { viewModel.selectPostalCode(plz) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plz.plz)
                                .font(.system(.headline, design: .default))
                            Text(plz.displayName)
                                .font(.system(.subheadline, design: .default))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        // ✅ Explicit height >= 44pt
                        .frame(minHeight: 44)
                    }
                    .accessibilityLabel("Postleitzahl \(plz.plz) — \(plz.city)")
                    .accessibilityAddTraits(.isButton)
                }
                .listStyle(.plain)
                .frame(maxHeight: 250)
            }
            
            // Auto-detect Button with minimum touch target
            Button(action: {
                Task { await viewModel.autodetectLocation() }
            }) {
                Label("Meinen Standort nutzen", systemImage: "location.fill")
                    .frame(maxWidth: .infinity)
                    // ✅ Minimum 44pt height
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                    // ✅ Entire frame is tappable (not just text)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoading)
        }
    }
}