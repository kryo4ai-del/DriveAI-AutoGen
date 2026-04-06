// ✅ ACCESSIBLE TIMELINE
struct ReviewScheduleView: View {
    let question: RememberedQuestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Text-first description
            Text("Next Review")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(nextReviewDateDescription)
                .font(.headline)
                .accessibilityLabel("Next review date")
                .accessibilityValue(nextReviewDateDescription)
                .accessibilityHint("This question will be available for review on this date")
            
            // Semantic progress indicator
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Review Due In")
                    Spacer()
                    Text("\(question.daysUntilReview) days")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                
                // Accessible progress bar
                ProgressView(
                    value: progressValue,
                    total: 1.0
                )
                .accessibilityLabel("Days until next review")
                .accessibilityValue(
                    "\(question.daysUntilReview) days remaining"
                )
            }
            
            // Timeline details with proper structure
            VStack(alignment: .leading, spacing: 6) {
                timelinePoint(
                    label: "Question Reviewed",
                    date: question.lastReviewDate ?? Date(),
                    isComplete: true
                )
                
                timelinePoint(
                    label: "Next Review Available",
                    date: question.nextReviewDate,
                    isComplete: false
                )
                
                if question.daysUntilReview > 7 {
                    Text("This question has been mastered and will be reviewed less frequently")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Status")
                        .accessibilityValue("Question mastered, reviewing less frequently")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Review schedule details")
        }
        .padding()
        .accessibilityElement(children: .contain)
    }
    
    private func timelinePoint(label: String, date: Date, isComplete: Bool) -> some View {
        HStack(spacing: 12) {
            // Status indicator
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle.dashed")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isComplete ? .green : .gray)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(dateFormatted(date))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(dateFormatted(date))
    }
    
    private var nextReviewDateDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let daysLeft = question.daysUntilReview
        if daysLeft <= 0 {
            return "Available today"
        } else if daysLeft == 1 {
            return "Tomorrow"
        } else {
            return formatter.string(from: question.nextReviewDate)
        }
    }
    
    private var progressValue: Double {
        // Progress from last review to next review date
        guard let lastReview = question.lastReviewDate else { return 0 }
        
        let interval = question.nextReviewDate.timeIntervalSince(lastReview)
        let elapsed = Date().timeIntervalSince(lastReview)
        
        return min(1.0, max(0.0, elapsed / interval))
    }
    
    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}