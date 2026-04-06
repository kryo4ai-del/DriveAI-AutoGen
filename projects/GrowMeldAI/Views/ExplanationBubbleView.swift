struct ExplanationBubbleView: View {
    let context: ExplanationContext
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: context.isUserCorrect ? "lightbulb.fill" : "exclamationmark.circle.fill")
                .foregroundColor(AppColors.feedback(context.isUserCorrect ? .correct : .incorrect))
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(context.displayExplanation)
                    .font(.driveAICaption2)
                    .foregroundColor(AppColors.textSecondary)
                
                if let stvoRef = context.stvoLink {
                    Link(destination: URL(string: "https://www.gesetze-im-internet.de/stvo/\(stvoRef)")!) {
                        Text("Learn more — §\(stvoRef)")
                            .font(.driveAICaption2)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppColors.secondaryBackground)
        .cornerRadius(8)
    }
}