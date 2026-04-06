var body: some View {
    VStack(spacing: 12) {
        if !viewModel.reviewPrompts.isEmpty {
            Text("Bereiche zum Üben")
                .font(.headline)
            
            // Group by priority
            ForEach(ReviewPriority.allCases, id: \.self) { priority in
                let prompts = viewModel.reviewPrompts.filter { $0.priority == priority }
                if !prompts.isEmpty {
                    Section(header: Text(priority.label).font(.subheadline)) {
                        ForEach(prompts) { prompt in
                            ReviewPromptRow(prompt)
                                .border(priority.accentColor, width: 2)
                        }
                    }
                }
            }
        }
    }
}

extension ReviewPriority {
    var label: String {
        switch self {
        case .critical: return "🔴 Dringend"
        case .high: return "🟠 Wichtig"
        case .medium: return "🟡 Mittelmäßig"
        case .low: return "🟢 Optional"
        }
    }
}