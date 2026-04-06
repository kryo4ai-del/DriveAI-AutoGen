import SwiftUI
struct TimerWidget: View {
    let timeRemaining: Int
    
    var body: some View {
        VStack {
            Text("Verbleibende Zeit")
                .font(.caption)
                .accessibilityHidden(true)  // Don't read label twice
            Text(formatTime(timeRemaining))
                .font(.title)
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Verbleibende Zeit")
        .accessibilityValue("\(timeRemaining / 60) Minuten, \(timeRemaining % 60) Sekunden")
        .accessibilityAddTraits(.updatesFrequently)  // Signal timer updates
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}