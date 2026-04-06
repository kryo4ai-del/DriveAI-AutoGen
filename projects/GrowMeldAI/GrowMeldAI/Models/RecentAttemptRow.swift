struct RecentAttemptRow: View {
    let exam: ExamAttempt
    let index: Int
    let total: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Prüfversuch")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                    
                    Text(exam.startTime, style: .date)
                        .font(.headline)
                    
                    Text(exam.startTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(exam.totalScore)/\(exam.maxScore)")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(exam.isPassed ? 
                        NSLocalizedString("passed", comment: "") : 
                        NSLocalizedString("failed", comment: "")
                    )
                    .font(.caption)
                    .foregroundColor(exam.isPassed ? .green : .red)
                }
            }
            
            ProgressView(value: Double(exam.totalScore), total: Double(exam.maxScore))
                .accessibilityLabel("Genauigkeit")
                .accessibilityValue(String(format: "%.0f%%", exam.accuracyPercentage))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(format:
            NSLocalizedString("exam_attempt_format", comment: ""),
            index, total
        ))
    }
}

// Usage:
ForEach(Array(recentExams.enumerated()), id: \.offset) { index, exam in
    RecentAttemptRow(exam: exam, index: index + 1, total: recentExams.count)
        .accessibilityHint(String(format:
            NSLocalizedString("exam_score_hint", comment: ""),
            exam.totalScore, exam.maxScore
        ))
}
.accessibilityElement(children: .contain)