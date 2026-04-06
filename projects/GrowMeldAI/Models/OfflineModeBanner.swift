struct OfflineModeBanner: View {
    @ObservedRealmObject var viewModel: QuestionViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Offline – Gepufferte Fragen verfügbar")
                    Text("Dein Fortschritt wird synchronisiert, wenn du online bist.")
                        .font(.caption)
                        .opacity(0.7)
                }
                
                Spacer()
                
                if viewModel.isSyncing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if viewModel.pendingAnswerCount > 0 {
                    Badge(viewModel.pendingAnswerCount)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            if viewModel.pendingAnswerCount > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "hourglass.bottomhalf.filled")
                    Text("\(viewModel.pendingAnswerCount) warten auf Sync")
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}