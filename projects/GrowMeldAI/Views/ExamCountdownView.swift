struct ExamCountdownView: View {
    let exam: ExamPreparation
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Prüfungsdatum")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if exam.isExamPassed {
                Text("Prüfung abgelaufen")
                    .font(.headline)
                    .foregroundColor(.white) // High contrast
                    .padding(8)
                    .background(Color.red)
                    .cornerRadius(4)
            } else {
                HStack(spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(exam.daysRemaining)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(exam.urgencyColor)
                            .accessibilityLabel("Tage bis zur Prüfung")
                            .accessibilityValue("\(exam.daysRemaining)")
                        
                        // CONTRAST FIX: Add background for guaranteed contrast
                        if exam.daysRemaining <= 3 {
                            Text("BALD!")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(4)
                                .accessibilityHidden(true)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Tage")
                            .font(.caption)
                        Text("verbleibend")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    private var exam: ExamPreparation {
        ExamPreparation(examDate: Date().addingTimeInterval(86400 * 7))
    }
}