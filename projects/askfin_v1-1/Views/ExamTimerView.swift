struct ExamTimerView: View {
    @ObservedObject var timerService: ExamTimerService
    
    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .accessibilityHidden(true) // Icon is decorative
            
            Text(timerService.displayTime)
                .font(.title2)
                .monospacedDigit()
                .accessibilityLabel("Zeit verbleibend")
                .accessibilityValue(accessibilityTimerValue)
                .accessibilityAddTraits(.updatesFrequently) // ← KEY!
            
            if timerService.timeRemaining < 300 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .accessibilityHidden(true) // Already in text value
            }
        }
        .padding()
        .background(timerService.timeRemaining < 60 ? Color.red.opacity(0.2) : Color.clear)
    }
    
    private var accessibilityTimerValue: String {
        let mins = timerService.timeRemaining / 60
        let secs = timerService.timeRemaining % 60
        
        if timerService.timeRemaining < 60 {
            return "\(secs) Sekunden verbleibend"
        } else {
            return "\(mins) Minuten \(secs) Sekunden verbleibend"
        }
    }
}