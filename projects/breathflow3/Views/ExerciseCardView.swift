struct ExerciseCardView: View {
    let exercise: Exercise
    // Remove onSelect callback
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ... card content ...
        }
        .contentShape(Rectangle())  // For better tap area
        .frame(minHeight: 44)
    }
}