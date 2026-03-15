import SwiftUI

// MARK: - TrendBadge

/// A compact pill indicating score trajectory: improving, stable, or declining.
///
/// DESIGN-011 note: `.stable` is always shown when a previous score exists.
/// If product decides to suppress `.stable` on first load, gate visibility
/// in the parent view using `ExamReadinessSnapshot.hasPreviousScore` once
/// that property is added.
struct TrendBadge: View {

    let trend: ReadinessScore.Trend

    var body: some View {
        Label(label, systemImage: trend.systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12), in: Capsule())
            .accessibilityLabel("Trend: \(label)")
    }

    // MARK: - Private

    private var label: String {
        switch trend {
        case .improving: return "Verbesserung"
        case .stable:    return "Stabil"
        case .declining: return "Rückgang"
        }
    }

    private var color: Color {
        switch trend {
        case .improving: return .green
        case .stable:    return Color(.secondaryLabel)
        case .declining: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        TrendBadge(trend: .improving)
        TrendBadge(trend: .stable)
        TrendBadge(trend: .declining)
    }
    .padding()
}