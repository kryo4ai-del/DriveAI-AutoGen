// Features/Diagnosis/Views/LearningGapCardView.swift
import SwiftUI

struct LearningGapCardView: View {
    let recommendation: Recommendation
    let isExpanded: Bool
    let onToggleExpansion: () -> Void
    let onAction: (DiagnosticAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // HEADER: Tap target for expansion
            Button(action: onToggleExpansion) {
                HStack(spacing: 12) {
                    // 1. Severity Indicator (a11y: icon + text)
                    VStack(alignment: .center, spacing: 2) {
                        Image(systemName: recommendation.gap.gapSeverity.systemImage)
                            .font(.title3)
                            .foregroundColor(recommendation.gap.gapSeverity.color)
                            .accessibilityHidden(true) // Text label is primary
                        
                        Text(recommendation.gap.gapSeverity.localizedName)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                    .frame(width: 50)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Schweregrad: \(recommendation.gap.gapSeverity.localizedName)")
                    
                    // 2. Gap topic + description
                    VStack(alignment: .leading, spacing: 2) {
                        Text(recommendation.gap.topic)
                            .font(.headline)
                            .lineLimit(2)
                        
                        Text(recommendation.gap.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // 3. Expansion chevron (visual only)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: 44) // ✅ WCAG 2.5.5: minimum touch target
                .padding(12)
                .contentShape(Rectangle()) // Expand tap area
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(recommendation.gap.accessibilityLabel)
            .accessibilityHint("Tippe zum \(isExpanded ? "Einklappen" : "Ausklappen") von Details")
            .accessibilityAddTraits(.isButton)
            
            // EXPANDED CONTENT
            if isExpanded {
                Divider()
                    .padding(.horizontal, 12)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Efficacy message
                    EfficacyMessageView(
                        gap: recommendation.gap,
                        efficacyMessage: recommendation.efficacyMessage,
                        nextStepHint: recommendation.nextStepHint
                    )
                    
                    // Scheduled reviews timeline
                    ScheduledReviewTimelineView(reviews: recommendation.scheduledReviews)
                    
                    // Action buttons
                    ActionButtonsView(
                        actions: recommendation.actionOptions,
                        gap: recommendation.gap,
                        onAction: onAction
                    )
                }
                .padding(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    recommendation.gap.gapSeverity == .critical
                        ? Color.red.opacity(0.3)
                        : Color.gray.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    LearningGapCardView(
        recommendation: Recommendation(
            id: UUID(),
            gap: LearningGap(
                id: UUID(),
                topicID: "vorfahrt",
                topic: "Vorfahrtsregeln",
                description: "Du hattest 3 Fehler bei Vorfahrtsfragen",
                gapSeverity: .critical,
                lastReviewedDate: nil,
                attemptCount: 1,
                successRate: 0.33,
                trafficSignID: nil,
                trafficSignName: nil,
                trafficSignMeaning: nil
            ),
            scheduledReviews: [
                ScheduledReview(id: UUID(), day: 1, description: "1. Wiederholung", practiceCount: 1, dueDate: .now),
                ScheduledReview(id: UUID(), day: 3, description: "2. Wiederholung", practiceCount: 2, dueDate: .now.addingTimeInterval(3*86400)),
                ScheduledReview(id: UUID(), day: 7, description: "3. Wiederholung", practiceCount: 2, dueDate: .now.addingTimeInterval(7*86400))
            ],
            actionOptions: [
                .practiceNow(topic: "Vorfahrtsregeln", questionCount: 5),
                .scheduleForLater(topic: "Vorfahrtsregeln", dueDate: .now.addingTimeInterval(3*86400))
            ],
            efficacyMessage: "Du erkennst jetzt, worauf du dich konzentrieren musst.",
            nextStepHint: "3 Übungen in den nächsten 7 Tagen werden dir helfen, diese Lücke zu schließen."
        ),
        isExpanded: true,
        onToggleExpansion: {},
        onAction: { _ in }
    )
    .padding()
}