struct SearchBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.blue)  // ← Brand color
            
            TextField(
                String(localized: "location_search_placeholder_focused"),
                text: $text,
                prompt: Text("z.B. 'Berlin' oder '10115'")  // ← Contextual hint
                    .foregroundColor(.secondary)
            )
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.blue.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.blue.opacity(0.05))  // ← Subtle brand color
        .cornerRadius(12)
        .border(Color.blue.opacity(0.2), width: 1)  // ← Consistent with onboarding
    }
}