struct ExamProgressView: View {
    let currentIndex: Int
    let totalQuestions: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            ProgressView(value: Double(currentIndex) / Double(totalQuestions))
            Text("\(currentIndex + 1)/\(totalQuestions)")
                .font(.caption)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress")
        .accessibilityHint("You are on question \(currentIndex + 1) of \(totalQuestions)")
    }
}