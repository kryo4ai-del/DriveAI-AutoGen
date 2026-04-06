struct QuotaProgressView: View {
    let usage: QuotaUsage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quotaLabel)
                        .font(.system(.subheadline, design: .default))
                        .foregroundColor(.secondary)
                    
                    Text("\(usage.remaining) / \(usage.limit)")
                        .font(.system(.headline, design: .default))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(resetLabel)
                        .font(.system(.caption, design: .default))
                        .foregroundColor(.secondary)
                    
                    Badge(level: usage.approachLevel)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .accessibilityHidden(true)  // ✅ FIX: Hide decorative bg
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * usage.percentageUsed)
                        .accessibilityHidden(true)  // ✅ Hide since parent has label
                    
                    // ✅ Hide animated layer from VoiceOver
                    if usage.approachLevel != .healthy {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(progressColor.opacity(0.3))
                            .frame(width: geometry.size.width * usage.percentageUsed)
                            .modifier(PulseModifier())
                            .accessibilityHidden(true)  // ✅ Don't re-announce
                    }
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Daily quota progress")
        .accessibilityValue(accessibilityQuotaValue)
        .accessibilityHint(accessibilityQuotaHint)  // ✅ FIX: Add context
    }
    
    private var accessibilityQuotaValue: String {
        let daily = usage
        return String(
            format: NSLocalizedString(
                "quota.a11y.value",
                value: "%d of %d questions. %@",
                comment: "Accessibility value for quota progress"
            ),
            daily.used,
            daily.limit,
            daily.approachLevel.accessibilityLabel
        )
    }
    
    private var accessibilityQuotaHint: String {
        switch usage.approachLevel {
        case .healthy:
            return NSLocalizedString(
                "quota.a11y.hint.healthy",
                value: "You can answer more questions today. Quota resets at midnight.",
                comment: ""
            )
        case .warning:
            return NSLocalizedString(
                "quota.a11y.hint.warning",
                value: "You're approaching your daily limit. Upgrade to Premium for unlimited questions.",
                comment: ""
            )
        case .critical:
            return NSLocalizedString(
                "quota.a11y.hint.critical",
                value: "You've reached today's limit. Come back tomorrow or upgrade to Premium.",
                comment: ""
            )
        }
    }
}