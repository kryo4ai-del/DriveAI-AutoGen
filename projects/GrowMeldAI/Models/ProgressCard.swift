// Extract: ProgressCard used in multiple views
struct ProgressCard<Content: View>: View {
    let title: String
    let progress: Double
    let content: () -> Content
    
    var body: some View {
        VStack {
            Text(title).font(.headline)
            ProgressView(value: progress)
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// Use everywhere:
ProgressCard(title: "Verkehrszeichen", progress: 0.75) {
    Text("18 von 24 beantwortet")
}