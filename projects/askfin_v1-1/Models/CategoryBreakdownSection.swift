import SwiftUI

// MARK: - CategoryBreakdownSection

/// Displays question categories grouped by status: Weak / In Progress / Mastered.
///
/// TODO: Add collapse/expand per group when category count > 5.
/// Mastered categories are the lowest priority for user attention and
/// should default to collapsed when the list is long (STRUCT-015).
struct CategoryBreakdownSection: View {

    let snapshot: ExamReadinessSnapshot

    /// Categories that are neither weak nor mastered.
    private var inProgress: [CategoryReadiness] {
        snapshot.categoryBreakdown.filter { !$0.isWeak && !$0.isMastered }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kategorien")
                .font(.title3.weight(.semibold))

            if snapshot.categoryBreakdown.isEmpty {
                emptyState
            } else {
                categoryGroups
            }
        }
    }

    // MARK: Private Views

    private var emptyState: some View {
        Text("Noch keine Kategorien gestartet.")
            .foregroundStyle(.secondary)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
    }

    @ViewBuilder
    private var categoryGroups: some View {
        if !snapshot.weakCategories.isEmpty {
            categoryGroup(
                title: "Verbesserungsbedarf",
                systemImage: "exclamationmark.triangle.fill",
                tint: .orange,
                categories: snapshot.weakCategories
            )
        }
        if !inProgress.isEmpty {
            categoryGroup(
                title: "In Bearbeitung",
                systemImage: "clock.fill",
                tint: .blue,
                categories: inProgress
            )
        }
        if !snapshot.masteredCategories.isEmpty {
            categoryGroup(
                title: "Gemeistert",
                systemImage: "checkmark.seal.fill",
                tint: .green,
                categories: snapshot.masteredCategories
            )
        }
    }

    private func categoryGroup(
        title: String,
        systemImage: String,
        tint: Color,
        categories: [CategoryReadiness]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(tint)

            VStack(spacing: 1) {
                ForEach(categories) { CategoryReadinessRow(category: $0) }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}