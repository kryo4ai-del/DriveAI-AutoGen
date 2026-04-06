struct QuotaStatusBar: View {
    @Environment(\.quotaManager) var quotaManager
    let onTap: (() -> Void)?  // Optional if interactive
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Tägeslimit")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if case .freeTierActive(let remaining) = quotaManager.state {
                    Text("\(remaining)/5")
                        .font(.caption2)
                        .monospacedDigit()
                }
            }
            
            if case .freeTierActive(let remaining) = quotaManager.state {
                ProgressView(value: Double(remaining) / 5.0)
                    .tint(quotaManager.state.limitApproach.borderColor)
                    .accessibilityLabel("Daily quota progress")
                    .accessibilityValue("\(remaining) of 5 questions remaining")
                    .accessibilityHint("Quota resets at midnight")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        // ✅ If tappable, ensure 44pt minimum:
        .frame(minHeight: onTap != nil ? 44 : .zero)
        .onTapGesture {
            onTap?()
        }
        // ✅ Mark non-interactive status as such:
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(onTap == nil ? .isStaticText : [])
    }
}