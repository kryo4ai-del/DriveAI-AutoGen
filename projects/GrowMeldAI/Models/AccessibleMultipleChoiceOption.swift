import SwiftUI

struct AccessibleMultipleChoiceOption: View {
    let optionNumber: Int
    let totalOptions: Int
    let text: String
    let isSelected: Bool
    let feedbackState: AnswerFeedbackState?
    let action: () -> Void
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                // Option indicator
                ZStack {
                    Circle()
                        .strokeBorder(borderColor, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(selectionColor)
                            .frame(width: 16, height: 16)
                    }
                }
                .accessibilityHidden(true)
                
                // Answer text
                Text(text)
                    .font(.body)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Feedback indicator
                if let feedback = feedbackState {
                    Image(systemName: feedback.iconName)
                        .foregroundColor(feedback.color)
                        .accessibilityHidden(true)
                }
                
                Spacer(minLength: 0)
            }
            .frame(minHeight: 48)  // ≥ 44pt minimum touch target
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Tippe zum Auswählen")
        .accessibilityAddTraits(.isButton)
        // Announce feedback immediately
        .onChange(of: feedbackState) { _, newState in
            if !reduceMotion {
                announceResult(newState)
            }
        }
    }
    
    // MARK: - Accessibility Properties
    
    private var accessibilityLabel: String {
        "Antwort \(optionNumber) von \(totalOptions)"
    }
    
    private var accessibilityValue: String {
        var value = text
        if let feedback = feedbackState {
            value += ", \(feedback.accessibilityLabel)"
        }
        return value
    }
    
    private func announceResult(_ state: AnswerFeedbackState?) {
        guard let state = state else { return }
        AccessibilityNotification.Announcement(state.announcementText).post()
    }
    
    // MARK: - Visual Properties
    
    private var borderColor: Color {
        if let feedback = feedbackState {
            return feedback.color
        }
        return isSelected ? .blue : .gray
    }
    
    private var selectionColor: Color {
        if let feedback = feedbackState {
            return feedback.color
        }
        return .blue
    }
    
    private var backgroundColor: Color {
        guard let feedback = feedbackState else {
            return Color(.systemBackground)
        }
        return feedback.backgroundColor
    }
}

// MARK: - Supporting Types

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        AccessibleMultipleChoiceOption(
            optionNumber: 1,
            totalOptions: 4,
            text: "An der Ampel bei Rot halten",
            isSelected: true,
            feedbackState: .correct,
            action: {}
        )
        
        AccessibleMultipleChoiceOption(
            optionNumber: 2,
            totalOptions: 4,
            text: "Vorsichtig weiterfahren",
            isSelected: false,
            feedbackState: nil,
            action: {}
        )
    }
    .padding()
}