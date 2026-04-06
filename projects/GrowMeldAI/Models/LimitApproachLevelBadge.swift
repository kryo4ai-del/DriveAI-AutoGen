struct LimitApproachLevelBadge: View {
    @EnvironmentObject var quotaManager: QuotaManager
    
    var body: some View {
        HStack(spacing: 6) {
            // Icon + color combination (not color alone)
            Image(systemName: quotaManager.limitApproachLevel.systemImage)
                .foregroundColor(quotaManager.limitApproachLevel.color)
            
            // TEXT IS REQUIRED - never color-only
            Text(quotaManager.limitApproachLevel.statusText)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Color(.systemGray5)
        )
        .cornerRadius(6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Quota-Status: \(quotaManager.limitApproachLevel.statusText)")
    }
}

// Add to LimitApproachLevel enum