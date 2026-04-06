struct FeatureBlockModal: View {
    let feature: TrialFeature
    let usedCount: Int
    let maxCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // ✅ Clear text + visual indicator
            VStack(alignment: .leading, spacing: 8) {
                Text("Exam Simulation Limit Reached")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                HStack(spacing: 12) {
                    // ✅ Icon + text (not color alone)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                        .accessibilityHidden(true)  // Icon is decorative
                    
                    Text("\(usedCount) of \(maxCount) free simulations completed")
                        .font(.body)
                        .accessibilityLabel("You have used \(usedCount) of \(maxCount) free exam simulations")
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // ✅ Progress bar with accessible label
            ProgressView(value: Double(usedCount), total: Double(maxCount))
                .accessibilityLabel("Simulation usage progress")
                .accessibilityValue("\(usedCount) of \(maxCount) used")
            
            // ✅ Clear CTA with sufficient size
            Button(action: { /* navigate to paywall */ }) {
                HStack {
                    Image(systemName: "lock.open")
                        .accessibilityHidden(true)
                    
                    Text("Unlock Unlimited Simulations")
                }
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 48)  // ✅ 44pt minimum
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .accessibilityLabel("Unlock unlimited exam simulations")
            .accessibilityHint("Removes the 3-simulation limit for your trial period")
        }
        .padding()
    }
}