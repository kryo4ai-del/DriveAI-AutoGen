struct TrialStatusView: View {
    @ObservedObject var trialVM: TrialViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ✅ Add semantic header
            Text("Trial Status")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            // ✅ Group countdown with clear labels
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Days Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(trialVM.daysRemaining)")
                        .font(.title2.weight(.semibold))
                        .accessibilityLabel("Days remaining in trial: \(trialVM.daysRemaining)")
                }
                
                Spacer()
                
                // ✅ Button must be 44x44 minimum
                Button(action: { /* navigate to paywall */ }) {
                    Text("Upgrade")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .accessibilityLabel("Upgrade to premium")
                .accessibilityHint("Removes trial limitations and unlocks all features")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding()
        .accessibilityElement(children: .combine)  // Group for VoiceOver
    }
}