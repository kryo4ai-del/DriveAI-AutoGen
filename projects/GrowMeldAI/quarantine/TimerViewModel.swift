@MainActor
final class TimerViewModel: ObservableObject {
    @Published var displayTime: String = "45:00"
    @Published var remainingSeconds: Int = 2700
    
    private var timerTask: Task<Void, Never>?
    
    func startTimer(onExpire: @escaping () -> Void) {
        timerTask = Task {
            while remainingSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
                
                await MainActor.run {
                    remainingSeconds -= 1
                    updateDisplayTime()
                    
                    // Announce critical times
                    if remainingSeconds == 300 {  // 5 minutes left
                        announceWarning("Fünf Minuten verbleibend")
                    } else if remainingSeconds == 60 {  // 1 minute left
                        announceWarning("Eine Minute verbleibend")
                    } else if remainingSeconds == 0 {
                        announceWarning("Zeit abgelaufen")
                        onExpire()
                    }
                }
            }
        }
    }
    
    private func announceWarning(_ message: String) {
        // Use AccessibilityAnnouncement
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// In TimerView
Text(timerViewModel.displayTime)
    .font(.system(.title, design: .monospaced))
    .foregroundColor(timerViewModel.remainingSeconds < 300 ? .red : .black)
    .accessibilityLabel("Time remaining")
    .accessibilityValue(formatTimeForVoiceOver(timerViewModel.remainingSeconds))
    .accessibilityAddTraits(.updatesFrequently)  // Tell VoiceOver to poll frequently