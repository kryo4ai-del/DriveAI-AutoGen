struct CategoryReadinessRow: View {
    let category: CategoryReadiness
    
    var body: some View {
        HStack(spacing: 12) {
            // ... content ...
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
        // ❌ No .focusable() or focus modifiers
    }
}