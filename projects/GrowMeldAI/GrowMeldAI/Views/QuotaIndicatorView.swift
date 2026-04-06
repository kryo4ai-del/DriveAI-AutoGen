struct QuotaIndicatorView: View {
    @EnvironmentObject var quotaManager: QuotaManager
    @State var showQuotaDetails = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header (minimum 44pt tall for touch safety)
            HStack {
                Label("Tägliches Limit", systemImage: "questionmark.circle.fill")
                    .font(.caption)
                Spacer()
                Text(quotaManager.getProgressText())
                    .font(.headline.monospacedDigit())
            }
            .frame(minHeight: 44)  // ← Ensure 44pt touch target
            
            // Progress bar (increase height for visibility + touch)
            ProgressView(
                value: quotaManager.quotaState.quotaPercentage,
                total: 1.0
            )
            .frame(height: 8)  // ← Increase from default 4pt to 8pt
            .tint(quotaManager.limitApproachLevel.color)
            
            // Status text (minimum 12pt font for WCAG AA)
            Text(quotaManager.limitApproachLevel.motivationalMessage)
                .font(.caption2.bold())  // ← At least 11pt recommended
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)  // ← Increase padding for touch spacing
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            showQuotaDetails = true
        }
        .sheet(isPresented: $showQuotaDetails) {
            QuotaDetailsView()
        }
        // VoiceOver: Announce entire card as logical unit
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tägliches Fragen-Limit")
        .accessibilityValue(quotaManager.getProgressText())
        .accessibilityHint("Tippen für Details. Du kannst \(quotaManager.quotaState.remainingToday) weitere Fragen heute beantworten.")
    }
}