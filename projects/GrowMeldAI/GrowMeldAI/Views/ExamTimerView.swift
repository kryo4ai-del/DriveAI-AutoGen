struct ExamTimerView: View {
    let timeRemaining: TimeInterval
    let examDuration: TimeInterval = 30 * 60
    
    var minutes: Int { Int(timeRemaining) / 60 }
    var seconds: Int { Int(timeRemaining) % 60 }
    var isWarning: Bool { timeRemaining < 5 * 60 }  // Last 5 minutes
    var isCritical: Bool { timeRemaining < 1 * 60 }  // Last minute
    
    var body: some View {
        VStack(spacing: 8) {
            Text(String(format: "%02d:%02d", minutes, seconds))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(isCritical ? .red : isWarning ? .orange : .primary)
                .monospacedDigit()  // Ensures consistent width
            
            ProgressView(value: timeRemaining, total: examDuration)
                .tint(isCritical ? .red : isWarning ? .orange : .green)
            
            Text("Time remaining")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Time remaining"))
        .accessibilityValue(Text(timerAccessibilityLabel))
        .accessibilityHint(Text("Exam duration is 30 minutes"))
        
        // Announce time changes at intervals (not every second)
        .onChange(of: minuteGroup) { _ in
            announceTime()
        }
    }
    
    private var timerAccessibilityLabel: String {
        if isCritical {
            return "\(seconds) seconds remaining. Hurry!"
        } else if isWarning {
            return "\(minutes) minutes and \(seconds) seconds remaining. Less than 5 minutes left."
        } else {
            return "\(minutes) minutes and \(seconds) seconds remaining"
        }
    }
    
    private var minuteGroup: Int {
        // Only announce when minute changes (every 60 seconds)
        minutes
    }
    
    private func announceTime() {
        UIAccessibility.post(notification: .announcement, argument: timerAccessibilityLabel)
    }
}

// Usage in ExamProgressView:
struct ExamProgressView: View {
    @ObservedObject var viewModel: ExamViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Question \(viewModel.questionsRemaining) of 30")
                Spacer()
                ExamTimerView(timeRemaining: viewModel.timeRemaining)
            }
            .accessibilityElement(children: .combine)
            
            // Question content...
        }
    }
}