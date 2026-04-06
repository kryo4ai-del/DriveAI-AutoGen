struct StreakIndicatorView: View {
    let streak: StreakData
    @State private var showStreakDetail = false
    
    var body: some View {
        Button(action: { showStreakDetail = true }) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(streak.current)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("Tage Serie")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                if streak.longest > streak.current {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                            .accessibilityHidden(true)
                        
                        Text("Rekord: \(streak.longest)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(minHeight: 44) // 44pt minimum touch target
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trainingssträhnung")
        .accessibilityValue("\(streak.current) Tage aktuell, \(streak.longest) Tage Rekord")
        .accessibilityHint("Berühren Sie den Bildschirm, um Streakdetails anzuzeigen")
        .sheet(isPresented: $showStreakDetail) {
            StreakDetailView(streak: streak)
        }
    }
}