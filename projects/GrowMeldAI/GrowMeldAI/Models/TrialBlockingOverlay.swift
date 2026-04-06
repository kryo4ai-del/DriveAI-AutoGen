struct TrialBlockingOverlay: View {
    @ObservedObject var coordinator: TrialCoordinator
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading) {
                    Text("Daily quota reached")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("You've answered your 10 questions for today. Try again tomorrow or upgrade for unlimited.")
                        .font(.body)
                        .accessibilityHint("Tap to view upgrade options")
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .border(Color.orange, width: 2)  // Non-color indicator
        }
        .accessibilityElement(children: .combine)
    }
}