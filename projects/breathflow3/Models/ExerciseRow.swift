struct ExerciseRow: View {
    let topic: ExerciseTopic
    let isPriority: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(topic.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                        
                        if isPriority {
                            Label("Priority", systemImage: "exclamationmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .labelStyle(.iconOnly)
                                .accessibilityLabel("Priority topic")
                        }
                    }
                    
                    Text("\(topic.questionCount) questions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(topic.title), \(topic.questionCount) questions")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(
            isPriority
                ? "Priority: recommended for review"
                : "Tap to start exercises"
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        ExerciseRow(
            topic: ExerciseTopic(id: "road-signs", title: "Road Signs", questionCount: 15, readiness: .topicsMastered, correctAnswers: 15),
            isPriority: false,
            action: {}
        )
        Divider()
        ExerciseRow(
            topic: ExerciseTopic(id: "speed-limits", title: "Speed Limits", questionCount: 8, readiness: .stillShaky, correctAnswers: 3),
            isPriority: true,
            action: {}
        )
    }
}