struct ExamSimulationView: View {
    @ObservedObject var viewModel: ExamSessionViewModel
    @State private var lastAnnouncedTime: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Timer Header (with dynamic announcements)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Verbleibende Zeit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(viewModel.timeRemaining))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.isTimeRunningOut ? .red : .primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Fragen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(viewModel.answeredCount)/\(viewModel.totalQuestions)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Prüfungsstatus")
            .accessibilityValue(
                "Verbleibende Zeit: \(formatTime(viewModel.timeRemaining)). "
                + "Fragen beantwortet: \(viewModel.answeredCount) von \(viewModel.totalQuestions)"
            )
            .onChange(of: viewModel.timeRemaining) { newTime in
                // Announce time warnings
                if newTime < 300 && newTime != lastAnnouncedTime { // 5 minutes
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: "Achtung: Nur noch \(formatTime(newTime)) Zeit verbleibend"
                    )
                    lastAnnouncedTime = newTime
                }
            }
            
            Divider()
            
            // Question display (same as QuestionView above)
            QuestionView(viewModel: viewModel.questionViewModel)
            
            Spacer()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Prüfungssimulation")
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}