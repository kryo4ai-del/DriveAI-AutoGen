struct HomeScreenMotivationBanner: View {
    let userProgress: UserProgress
    let daysUntilExam: Int
    
    var body: some View {
        if daysUntilExam > 0 && daysUntilExam <= 90 {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Exam")
                            .font(.caption, weight: .semibold)
                            .foregroundColor(.secondary)
                        
                        if daysUntilExam == 1 {
                            Text("Tomorrow!")
                                .font(.headline)
                                .foregroundColor(.red)
                        } else if daysUntilExam <= 7 {
                            Text("\(daysUntilExam) days away")
                                .font(.headline)
                                .foregroundColor(.orange)
                        } else {
                            Text("\(daysUntilExam) days to prepare")
                                .font(.headline)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Exam countdown")
                .accessibilityValue("\(daysUntilExam) days remaining")
                
                // Adaptive recommendation (no judgment)
                if daysUntilExam <= 14 {
                    Text("Recommended: 2–3 sessions today to stay on track")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Daily recommendation based on time until exam")
                } else if daysUntilExam <= 7 {
                    Text("⚠️ Increase sessions to 3–4 daily for final review")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
}