import SwiftUI

/// Displays all 16 topics grouped by domain with competence level indicators.
/// Overall readiness score is shown prominently at the top.
struct SkillMapView: View {

    @StateObject private var viewModel: SkillMapViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Two-column grid — four columns fail contrast and tap-target requirements
    // at 375pt screen width (93pt per cell is too narrow for icon + label).
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    init(viewModel: SkillMapViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                readinessHeader
                ForEach(viewModel.domainSections, id: \.domain) { section in
                    domainSection(section)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Lernstand")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Readiness Header

    private var readinessHeader: some View {
        VStack(spacing: 6) {
            Text(viewModel.readinessLabel)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Prüfungsbereitschaft")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let deltaLabel = viewModel.projectedDeltaLabel {
                Text(deltaLabel)
                    .font(.caption)
                    .foregroundStyle(.green)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Prüfungsbereitschaft: \(viewModel.readinessLabel). "
            + (viewModel.projectedDeltaLabel ?? "")
        )
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Domain Section

    private func domainSection(_ section: DomainSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text(section.domain.displayName)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                if section.isFullyMastered {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .accessibilityLabel("Vollständig gemeistert")
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(
                section.domain.displayName
                + (section.isFullyMastered ? ", vollständig gemeistert" : "")
            )

            // Topic grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(section.competences, id: \.topic) { competence in
                    TopicCell(
                        competence: competence,
                        isDue: isDue(competence.topic),
                        reduceMotion: reduceMotion
                    )
                    .frame(minHeight: 88)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // TODO: Navigate to topic detail view
                        print("[SkillMapView] Topic tapped: \(competence.topic.displayName)")
                    }
                    .accessibilityLabel(cellAccessibilityLabel(for: competence))
                    .accessibilityHint("Zeigt Details zu \(competence.topic.displayName)")
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
    }

    // MARK: - Helpers

    private func isDue(_ topic: TopicArea) -> Bool {
        // SkillMapViewModel does not expose spacingQueue directly;
        // drive isDue from competenceLevel as a proxy (notStarted/weak = effectively due)
        // TODO: Expose spacingQueue on SkillMapViewModel for accurate due-date checking.
        let level = viewModel.competences.first(where: { $0.topic == topic })?.competenceLevel
        return level == .notStarted || level == .weak
    }

    private func cellAccessibilityLabel(for competence: TopicCompetence) -> String {
        let level = competence.competenceLevel.localizedName
        let answers = competence.totalAnswers
        return "\(competence.topic.displayName): \(level). \(answers) Antworten."
    }
}

// MARK: - TopicCell

private struct TopicCell: View {

    let competence: TopicCompetence
    let isDue: Bool
    let reduceMotion: Bool

    @State private var pulseOpacity: Double = 0.4

    var body: some View {
        ZStack {
            // Base background — always dark, never fillColor (avoids contrast failures)
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(white: 0.12))

            // Competence border
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(competence.competenceLevel.fillColor, lineWidth: 2)

            // Content
            VStack(spacing: 8) {
                Image(systemName: competence.topic.symbolName)
                    .font(.title2)
                    .foregroundStyle(competence.competenceLevel.fillColor)

                Text(competence.topic.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if competence.totalAnswers > 0 {
                    Text("\(competence.correctAnswers)/\(competence.totalAnswers)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(8)

            // Due indicator pulse
            if isDue && !reduceMotion {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
                    .opacity(pulseOpacity)
                    .offset(x: 30, y: -30)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            pulseOpacity = 1.0
                        }
                    }
            }
        }
    }
}
