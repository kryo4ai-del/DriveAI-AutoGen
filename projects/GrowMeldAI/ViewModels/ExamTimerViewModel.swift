@MainActor
class ExamTimerViewModel: ObservableObject {
    @Published var timeRemaining: Int
    @Published var lastAnnouncedTime: Int?
    
    func updateTimer() {
        timeRemaining -= 1
        
        // Announce at critical thresholds
        if timeRemaining == 300 && lastAnnouncedTime != 300 {
            UIAccessibility.post(notification: .announcement, argument: "5 Minuten verbleibend")
            lastAnnouncedTime = 300
        } else if timeRemaining == 60 && lastAnnouncedTime != 60 {
            UIAccessibility.post(notification: .announcement, argument: "1 Minute verbleibend")
            lastAnnouncedTime = 60
        } else if timeRemaining == 0 {
            UIAccessibility.post(notification: .announcement, argument: "Zeit ist abgelaufen")
        }
    }
}

// In View:
Text(String(format: "%02d:%02d", minutes, seconds))
    .font(.title)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Verbleibende Zeit")
    .accessibilityValue(String(format: "%d Minuten %d Sekunden", minutes, seconds))
    .accessibilityAddTraits(.updatesFrequently)