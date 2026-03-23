import SwiftUI

// MARK: - ReadinessHeaderSection

/// Displays the score gauge, trend badge, contextual statement, and exam
/// date supplement label.
///
/// Day count deduplication (DESIGN-012): `contextualStatement` already
/// embeds the day reference when `daysUntilExam > 0`, so no separate
/// countdown label is shown in that case.
struct ReadinessHeaderSection: View {

    let snapshot: ExamReadinessSnapshot

    var body: some View {
        VStack(spacing: 20) {
            ReadinessScoreGauge(score: snapshot.score)

            TrendBadge(trend: snapshot.score.trend)

            contextualLabel

            examSupplementLabel
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: Private Views

    private var contextualLabel: some View {
        Text(snapshot.contextualStatement)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 8)
    }

    /// Supplemental exam date label shown only when `contextualStatement`
    /// does not already carry a day reference (DESIGN-012).
    ///
    /// - Exam passed: completion banner.
    /// - No exam date: prompt to set one.
    /// - Future exam date: suppressed — day count is in contextualStatement.
    @ViewBuilder
    private var examSupplementLabel: some View {
        if snapshot.examHasPassed {
            examPassedBanner
        } else if snapshot.daysUntilExam == nil {
            Label("Kein Prüfungstermin gesetzt", systemImage: "calendar.badge.plus")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        // daysUntilExam > 0: contextualStatement already contains the
        // day reference. Nothing additional is shown here.
    }

    private var examPassedBanner: some View {
        Label("Prüfung abgeschlossen", systemImage: "checkmark.seal")
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.secondary, in: Capsule())
    }
}