// Features/Diagnosis/Views/SeverityIndicatorView.swift
struct SeverityIndicatorView: View {
    let severity: GapSeverity
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: severity.systemImage)
                .font(.headline)
                .foregroundColor(severity.color)
                .accessibilityHidden(true) // Text label below is primary
            
            Text(severity.localizedName)
                .font(.caption)
                .fontWeight(.semibold)
                .accessibilityLabel("Schweregrad: \(severity.localizedName)")
        }
        .frame(width: 50)
    }
}

// Features/Diagnosis/Views/ScheduledReviewTimelineView.swift

// Features/Diagnosis/Views/ActionButtonsView.swift
struct ActionButtonsView: View {
    let actions: [DiagnosticAction]
    let gap: LearningGap
    let onAction: (DiagnosticAction) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(actions, id: \.id) { action in
                ActionButton(
                    action: action,
                    gap: gap,
                    onTap: { onAction(action) }
                )
            }
        }
        .padding(12)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Aktionen für: \(gap.topic)")
    }
}

struct ActionButton: View {
    let action: DiagnosticAction
    let gap: LearningGap
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(width: 20, alignment: .center)
                    .accessibilityHidden(true)
                
                Text(action.label)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white)
                    .accessibilityHidden(true)
            }
            .frame(height: 44) // ✅ WCAG 2.5.5 minimum touch target
            .padding(.horizontal, 12)
            .background(buttonColor)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.accessibilityLabel)
        .accessibilityAddTraits(.isButton)
    }
    
    private var buttonColor: Color {
        switch action {
        case .practiceNow: return .blue
        case .scheduleForLater: return .green
        case .markAsReview: return .orange
        case .skipForNow: return .gray
        }
    }
}

// Features/Diagnosis/Views/EfficacyMessageView.swift