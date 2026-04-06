// In ExamScreen.swift that displays timer
struct ExamScreen: View {
    @ObservedObject var viewModel: ExamSimulationViewModel
    
    var body: some View {
        VStack {
            // Timer display
            HStack {
                Image(systemName: "clock.fill")
                    .accessibilityHidden(true)
                
                Text(formattedTime(viewModel.remainingSeconds))
                    .font(DesignTokens.Typography.h2)
                    .foregroundColor(timerColor)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Time remaining")
                    .accessibilityValue(timeAccessibilityValue)
                    // ✅ CRITICAL: Mark as live region
                    .accessibilityLiveRegion(.polite)
                    .id(UUID())  // Force VoiceOver to announce changes
            }
            
            // Rest of exam...
        }
    }
    
    private var timeAccessibilityValue: String {
        let minutes = viewModel.remainingSeconds / 60
        let seconds = viewModel.remainingSeconds % 60
        
        if viewModel.remainingSeconds <= 60 {
            return "\(seconds) seconds remaining"
        } else {
            return "\(minutes) minutes, \(seconds) seconds remaining"
        }
    }
    
    private var timerColor: Color {
        switch viewModel.remainingSeconds {
        case 0..<300:  // < 5 min
            return ColorPalette.current.warning
        case 300..<600:  // 5-10 min
            return ColorPalette.current.textSecondary
        default:
            return ColorPalette.current.primary
        }
    }
    
    private func formattedTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}