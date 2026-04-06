// ActionButtonsView.swift
import SwiftUI

struct ActionButtonsView: View {
    let actions: [DiagnosticAction]
    let gap: LearningGap
    let onAction: (DiagnosticAction) -> Void

    private var buttonColor: Color {
        switch gap.gapSeverity {
        case .critical: return .red
        case .moderate: return .orange
        case .minor: return .green
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(actions, id: \.self) { action in
                ActionButton(
                    action: action,
                    gap: gap,
                    onTap: { onAction(action) }
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(action.accessibilityLabel)
                .accessibilityHint(action.accessibilityHint)
            }
        }
    }
}

private struct ActionButton: View {
    let action: DiagnosticAction
    let gap: LearningGap
    let onTap: () -> Void

    private var buttonColor: Color {
        switch action {
        case .practiceNow: return .blue
        case .scheduleForLater: return .purple
        case .markAsReview: return .green
        case .skipForNow: return .gray
        }
    }

    private var buttonTitle: String {
        switch action {
        case .practiceNow(let topic, let count):
            return String(format: NSLocalizedString("practice_now_format", comment: "Practice {count} questions on {topic}"), count, topic)
        case .scheduleForLater(let topic, _):
            return String(format: NSLocalizedString("schedule_later_format", comment: "Schedule {topic} for later"), topic)
        case .markAsReview(let topic):
            return String(format: NSLocalizedString("mark_review_format", comment: "Mark {topic} as reviewed"), topic)
        case .skipForNow(let topic, _):
            return String(format: NSLocalizedString("skip_now_format", comment: "Skip {topic} for now"), topic)
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: action.systemImage)
                Text(buttonTitle)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(buttonColor)
        .controlSize(.large)
    }
}

private extension DiagnosticAction {
    var systemImage: String {
        switch self {
        case .practiceNow: return "book.fill"
        case .scheduleForLater: return "calendar.badge.plus"
        case .markAsReview: return "checkmark.circle"
        case .skipForNow: return "arrow.right.circle"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .practiceNow(let topic, let count):
            return String(format: NSLocalizedString("practice_now_accessibility", comment: "Practice {count} questions on {topic}"), count, topic)
        case .scheduleForLater(let topic, _):
            return String(format: NSLocalizedString("schedule_later_accessibility", comment: "Schedule {topic} for later"), topic)
        case .markAsReview(let topic):
            return String(format: NSLocalizedString("mark_review_accessibility", comment: "Mark {topic} as reviewed"), topic)
        case .skipForNow(let topic, _):
            return String(format: NSLocalizedString("skip_now_accessibility", comment: "Skip {topic} for now"), topic)
        }
    }

    var accessibilityHint: String {
        switch self {
        case .practiceNow:
            return NSLocalizedString("practice_now_hint", comment: "Starts active recall practice for this topic")
        case .scheduleForLater:
            return NSLocalizedString("schedule_later_hint", comment: "Schedules spaced repetition for this topic")
        case .markAsReview:
            return NSLocalizedString("mark_review_hint", comment: "Updates your learning progress")
        case .skipForNow:
            return NSLocalizedString("skip_now_hint", comment: "Skips this topic for now")
        }
    }
}