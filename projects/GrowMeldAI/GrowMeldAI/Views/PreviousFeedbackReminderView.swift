// Features/Feedback/Views/PreviousFeedbackReminderView.swift
struct PreviousFeedbackReminderView: View {
    let feedback: UserFeedback
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text("Du warst unsicher:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
            }
            
            if let text = feedback.text {
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .italic()
            } else {
                Text(feedback.category.label)
                    .font(.body)
                    .foregroundColor(.primary)
                    .italic()
            }
            
            Text("Verstehst du jetzt besser?")
                .font(.caption)
                .foregroundColor(.secondary)
                .marginTop(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.orange.opacity(0.08))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Du warst unsicher: \(feedback.text ?? feedback.category.label)")
    }
}