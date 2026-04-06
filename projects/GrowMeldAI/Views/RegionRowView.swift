struct RegionRowView: View {
    // ... existing properties ...
    @ObservedRealmObject var viewModel: LocationFilterViewModel
    
    var body: some View {
        // ...
        if let progress = viewModel.regionalProgress[region.id] {
            ProgressView(
                value: Double(progress.correctCount),
                total: Double(progress.answeredCount)
            )
            .tint(.green)
            
            Text("\(progress.correctCount)/\(progress.answeredCount) korrekt")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        // ...
    }
}