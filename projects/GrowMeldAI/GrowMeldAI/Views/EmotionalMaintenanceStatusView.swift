import SwiftUI

/// Status view with emotional hook and exam readiness cues.
struct EmotionalMaintenanceStatusView: View {
    let check: MaintenanceCheck
    let showDaysLabel: Bool
    let onTapAction: (() -> Void)?

    @Environment(\.locale) private var locale

    private var statusColor: Color {
        switch check.status {
        case .completed: return .green
        case .dueSoon: return .yellow
        case .overdue: return .red
        }
    }

    private var statusPattern: String {
        return check.status.localizedLabel
    }

    private var accessibilityLabel: String {
        let days = check.daysSinceLastPractice ?? 0
        return "\(check.categoryName): \(statusPattern). \(check.status.readinessCue) \(days > 0 ? "\(days) Tage seit letzter Übung." : "")"
    }

    private var label: String {
        let pattern = check.status.localizedLabel
        let days = check.daysSinceLastPractice.map { "\($0)" } ?? "?"
        return "\(check.categoryName): \(pattern) (\(days)T)"
    }

    var body: some View {
        Button(action: { onTapAction?() }) {
            HStack {
                Image(systemName: check.status.systemImage)
                    .foregroundColor(statusColor)
                Text(label)
                    .font(.body.weight(.medium))
                if showDaysLabel {
                    Text("(\(check.daysSinceLastPractice ?? 0)T)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .accessibilityLabel(Text(accessibilityLabel))
            .accessibilityAddTraits(.isButton)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions for Emotional Hooks
extension MaintenanceStatus {
    var systemImage: String {
        switch self {
        case .completed: return "checkmark.circle.fill"
        case .dueSoon: return "exclamationmark.triangle.fill"
        case .overdue: return "xmark.circle.fill"
        }
    }
}