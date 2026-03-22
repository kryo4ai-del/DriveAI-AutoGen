struct ReadinessCard: View {
    let viewModel: ReadinessCardViewModel
    let isCompact: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(viewModel.state.accentColor)
                    .frame(width: 12, height: 12)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.state.displayText)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .accessibilityLabel(viewModel.state.accessibilityLabel)
                    
                    if !viewModel.motivationalMessage.isEmpty {
                        Text(viewModel.motivationalMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.85)
                            .accessibilityAddTraits(.summaryElement)
                    }
                }
                Spacer()
            }
            
            if !isCompact {
                ProgressView(value: viewModel.progressPercentage)
                    .tint(viewModel.state.accentColor)
                    .accessibilityLabel("Progress: \(Int(viewModel.progressPercentage * 100))%")
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
    }
}

#Preview {
    VStack(spacing: 16) {
        ReadinessCard(
            viewModel: .build(state: .topicsMastered, correctAnswers: 10, totalQuestions: 10),
            isCompact: false
        )
        ReadinessCard(
            viewModel: .build(state: .stillShaky, correctAnswers: 5, totalQuestions: 10),
            isCompact: false
        )
    }
    .padding()
}