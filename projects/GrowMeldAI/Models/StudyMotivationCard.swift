struct StudyMotivationCard: View {
    let primaryOption: StudyOption
    var onSelect: (StudyOption) -> Void
    
    @State private var selectedOption: StudyOption?
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach([primaryOption] + otherOptions) { option in
                Button(action: { selectOption(option) }) {
                    HStack {
                        Text(option.displayLabel)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .opacity(0.6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor.opacity(0.08))
                            
                            if selectedOption?.id == option.id {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.accentColor)
                                    .scaleEffect(x: 1.0, y: 1.0, anchor: .leading)
                                    .animation(.easeInOut(duration: 0.3), value: selectedOption)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(option.displayLabel)
                .accessibilityHint(option.motivationalMessage)
            }
        }
    }
    
    private func selectOption(_ option: StudyOption) {
        triggerHapticFeedback()
        selectedOption = option
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onSelect(option)
        }
    }
    
    private func triggerHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.prepare()
        impact.impactOccurred()
    }
}