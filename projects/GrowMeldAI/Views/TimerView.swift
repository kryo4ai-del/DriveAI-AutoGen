// Views/Shared/TimerView.swift
struct TimerView: View {
    let secondsRemaining: Int
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(spacing: 4) {
            Text(formattedTime)
                .font(.system(.title, design: .monospaced))
                .fontWeight(.bold)
                .accessibility(hidden: true)  // Hide visual timer
            
            // ✅ ANNOUNCE TIME IN NATURAL LANGUAGE
            Text(timeAnnouncementText)
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibility(hidden: false)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        // ✅ ANNOUNCE STATUS UPDATES TO VOICEOVER
        .accessibilityElement(children: .combine)
        .accessibility(label: Text("Verbleibende Zeit"))
        .accessibility(value: Text(timeAnnouncementText))
        .onReceive(timer) { _ in
            // Announce remaining time every minute
            if secondsRemaining % 60 == 0 {
                UIAccessibility.post(notification: .announcement, argument: timeAnnouncementText)
            }
        }
    }
    
    private var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var timeAnnouncementText: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        
        if minutes == 0 {
            return "\(seconds) Sekunde\(seconds == 1 ? "" : "n")"
        } else {
            return "\(minutes) Minute\(minutes == 1 ? "" : "n") und \(seconds) Sekunde\(seconds == 1 ? "" : "n")"
        }
    }
    
    private var timer: Timer {
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
}