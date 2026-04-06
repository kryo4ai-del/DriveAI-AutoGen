struct TrialBadge: View {
    @ObservedObject var trialManager: TrialStateManager
    
    // ✅ Allow dependency injection + default to singleton
    init(trialManager: TrialStateManager = TrialStateManager.shared) {
        self._trialManager = ObservedObject(wrappedValue: trialManager)
    }
    
    var body: some View {
        if trialManager.isTrialActive,
           let daysRemaining = trialManager.daysRemaining {
            
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .accessibilityHidden(true)
                
                Text("\(daysRemaining) Tage gratis")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Kostenlose Testphase")
            .accessibilityValue("\(daysRemaining) Tage verbleibend")
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.accentColor)
            .cornerRadius(6)
            .transition(.opacity)
        }
    }
}

// ✅ Preview with test mock
#Preview("Active Trial") {
    let mockTrialManager = TrialStateManager()
    mockTrialManager.startTrial()
    return TrialBadge(trialManager: mockTrialManager)
        .padding()
}

#Preview("No Trial") {
    TrialBadge(trialManager: TrialStateManager())
        .padding()
}