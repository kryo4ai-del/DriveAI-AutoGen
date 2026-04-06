// MARK: - Define Accessible Color Palette (Utilities/AppColors.swift)
enum AppColors {
    // Feedback colors with accessibility-approved text colors
    static let correctBackground = Color(red: 0.95, green: 0.98, blue: 0.95) // Light green
    static let correctForeground = Color(red: 0.1, green: 0.5, blue: 0.1)    // Dark green
    static let correctAccent = Color.green
    
    static let incorrectBackground = Color(red: 0.98, green: 0.95, blue: 0.95) // Light red
    static let incorrectForeground = Color(red: 0.7, green: 0.0, blue: 0.0)   // Dark red
    static let incorrectAccent = Color.red
    
    static let neutralBackground = Color(red: 0.97, green: 0.97, blue: 1.0)  // Light blue
    static let neutralForeground = Color(red: 0.0, green: 0.0, blue: 0.5)    // Dark blue
}

// MARK: - FeedbackOverlay with Accessible Colors
struct FeedbackOverlay: View {
    let feedback: AnswerFeedback
    
    var backgroundAndForeground: (background: Color, foreground: Color, accent: Color) {
        if feedback.isCorrect {
            return (
                background: AppColors.correctBackground,
                foreground: AppColors.correctForeground,
                accent: AppColors.correctAccent
            )
        } else {
            return (
                background: AppColors.incorrectBackground,
                foreground: AppColors.incorrectForeground,
                accent: AppColors.incorrectAccent
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: feedback.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(backgroundAndForeground.accent)
                    .accessibilityHidden(true)
                
                Text(feedback.message)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(backgroundAndForeground.foreground)
            }
            
            Text(feedback.explanation)
                .font(.body)
                .foregroundColor(backgroundAndForeground.foreground)
                .lineLimit(nil)
        }
        .padding()
        .background(backgroundAndForeground.background)
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            feedback.isCorrect ? "Richtig" : "Falsch"
        )
        .accessibilityValue(feedback.explanation)
    }
}