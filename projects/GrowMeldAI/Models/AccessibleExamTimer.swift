import SwiftUI
import Combine

struct AccessibleExamTimer: View {
    let totalSeconds: Int
    let secondsRemaining: Int
    let onTimeExpired: () -> Void
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    // MARK: - State Management
    @State private var timerCancellable: AnyCancellable?
    @State private var hasExpired = false
    @State private var announcedTimes: Set<Int> = []
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Verbleibende Zeit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(formattedTime)
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                
                Spacer()
                
                if isWarningTime {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                        .accessibilityHidden(true)
                }
            }
            .padding(12)
            .background(timerBackground)
            .cornerRadius(8)
        }
        .accessibilityElement(combining: .all)
        .accessibilityLabel("Verbleibende Zeit")
        .accessibilityValue(accessibilityTimeValue)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityAddTraits(isWarningTime ? .causesPageTurn : [])
        // Lifecycle management
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .onChange(of: secondsRemaining) { _, _ in
            announceTimeIfNeeded()
        }
    }
    
    // MARK: - Timer Lifecycle
    
    private func startTimer() {
        guard timerCancellable == nil else { return }
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkTimeExpired()
            }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func checkTimeExpired() {
        guard !hasExpired, secondsRemaining <= 0 else { return }
        
        hasExpired = true
        stopTimer()
        
        // Announce expiration before callback
        if !reduceMotion {
            AccessibilityNotification.Announcement(
                "Die Zeit ist abgelaufen. Die Prüfung wird eingereicht."
            ).post()
        }
        
        onTimeExpired()
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Accessibility Announcements
    
    private func announceTimeIfNeeded() {
        guard !reduceMotion, !hasExpired else { return }
        
        let milestones = [300, 180, 120, 60, 30, 10, 5, 4, 3, 2, 1]
        
        if milestones.contains(secondsRemaining) && 
           !announcedTimes.contains(secondsRemaining) {
            announcedTimes.insert(secondsRemaining)
            
            let announcement = timeAnnouncement(for: secondsRemaining)
            AccessibilityNotification.Announcement(announcement).post()
        }
    }
    
    private func timeAnnouncement(for seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        
        if seconds >= 60 {
            let plural = minutes == 1 ? "Minute" : "Minuten"
            return "Noch \(minutes) \(plural)"
        } else {
            let plural = secs == 1 ? "Sekunde" : "Sekunden"
            return "Noch \(secs) \(plural)"
        }
    }
    
    // MARK: - Properties
    
    private var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var isWarningTime: Bool {
        secondsRemaining < 300 && secondsRemaining > 0
    }
    
    private var accessibilityTimeValue: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return "\(minutes) Minuten, \(seconds) Sekunden"
    }
    
    private var accessibilityHint: String {
        isWarningTime ? "Warnung: Weniger als 5 Minuten verbleibend" : "Zeitlimit für die Prüfung"
    }
    
    private var timerBackground: Color {
        isWarningTime ? Color(red: 1.0, green: 0.95, blue: 0.9) : Color(.systemBackground)
    }
}

// MARK: - Preview

#Preview("Normal Time") {
    AccessibleExamTimer(
        totalSeconds: 1800,
        secondsRemaining: 950,
        onTimeExpired: {}
    )
    .padding()
}

#Preview("Warning Time") {
    AccessibleExamTimer(
        totalSeconds: 1800,
        secondsRemaining: 280,
        onTimeExpired: {}
    )
    .padding()
}