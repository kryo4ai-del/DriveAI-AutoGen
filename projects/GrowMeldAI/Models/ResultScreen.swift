struct ResultScreen: View {
    let examResult: ExamResult
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Main result section
                VStack(spacing: 12) {
                    if examResult.session.isPassed {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.correctAnswer)
                            Text("Bestanden!")
                                .font(.title)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Exam passed")
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.incorrectAnswer)
                            Text("Nicht bestanden")
                                .font(.title)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Exam failed")
                    }
                    
                    Text("\(examResult.session.score)/\(examResult.session.configuration.totalQuestions)")
                        .font(.largeTitle)
                        .bold()
                        .accessibilityLabel("Score: \(examResult.session.score) out of \(examResult.session.configuration.totalQuestions)")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Exam Result")
                .accessibilityHint("Overall score and pass/fail status")
                
                Divider()
                
                // Category breakdown section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Kategorieübersicht")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    ForEach(Array(examResult.categoryBreakdown.enumerated()), id: \.offset) { _, entry in
                        CategoryResultRow(category: entry.key, correct: entry.value)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Category Breakdown")
                .accessibilityHint("Your score by category")
            }
            .padding()
        }
    }
}

struct CategoryResultRow: View {
    let category: String
    let correct: Int
    
    var body: some View {
        HStack {
            Text(category)
                .font(.body)
            Spacer()
            Text("\(correct)/10")
                .font(.body)
                .bold()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category): \(correct) correct")
    }
}