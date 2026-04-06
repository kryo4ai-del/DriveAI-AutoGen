// ✅ Good: Announced timer with alerts
struct ExamSessionView: View {
    @ObservedObject var viewModel: ExamViewModel
    @State private var lastAnnouncedTime: Int?
    
    var body: some View {
        VStack {
            // Timer Display
            HStack {
                VStack(alignment: .leading) {
                    Text("Verbleibende Zeit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(viewModel.examTimer.remainingSeconds))
                        .font(.title)
                        .monospacedDigit()
                }
                
                // Visual progress
                CircularProgressView(
                    progress: 1.0 - viewModel.examTimer.progress,
                    lineWidth: 8
                )
                .frame(width: 60, height: 60)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Prüfungszeit")
            .accessibilityValue(timeRemaining)
            .accessibilityAddTraits(.updatesFrequently)
            .onChange(of: viewModel.examTimer.remainingSeconds) { newTime in
                announceTimeIfNeeded(newTime)
            }
            
            // Question and answers...
        }
        .onAppear {
            UIAccessibility.post(
                notification: .announcement,
                argument: "Prüfung gestartet. 20 Minuten verfügbar. 30 Fragen."
            )
        }
    }
    
    private var timeRemaining: String {
        let minutes = viewModel.examTimer.remainingSeconds / 60
        let seconds = viewModel.examTimer.remainingSeconds % 60
        return String(format: "%d Minute%s %d Sekunde%s",
            minutes, minutes != 1 ? "n" : "",
            seconds, seconds != 1 ? "n" : "")
    }
    
    private func announceTimeIfNeeded(_ time: Int) {
        let shouldAnnounce = [
            1200, // Start
            900,  // 15 min remaining
            600,  // 10 min remaining
            300,  // 5 min remaining
            60,   // 1 min remaining
            30    // 30 sec remaining
        ]
        
        if shouldAnnounce.contains(time) && lastAnnouncedTime != time {
            lastAnnouncedTime = time
            let minutes = time / 60
            let announcement = minutes > 0 
                ? "Noch \(minutes) Minute\(minutes != 1 ? "n" : "")"
                : "Weniger als eine Minute verbleibend"
            
            UIAccessibility.post(
                notification: .announcement,
                argument: announcement
            )
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}