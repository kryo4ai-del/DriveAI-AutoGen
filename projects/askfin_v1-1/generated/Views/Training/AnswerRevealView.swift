import SwiftUI

struct AnswerRevealView: View {

    let question: SessionQuestion
    let wasCorrect: Bool
    let missDistance: Int
    let selectedDirection: SwipeDirection
    let isLastQuestion: Bool
    let previousCompetenceLevel: CompetenceLevel
    let currentCompetenceLevel: CompetenceLevel
    let onContinue: () -> Void

    @State private var isExplanationExpanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var accentColor: Color {
        wasCorrect ? .green : Color(red: 1.0, green: 0.27, blue: 0.27)
    }

    private var correctOption: AnswerOption {
        question.options[question.correctIndex]
    }

    private var continueLabel: String {
        isLastQuestion ? "Auswertung ansehen" : "Weiter"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                resultHeader
                correctAnswerCard
                if !wasCorrect {
                    wrongDirectionRow
                }
                explanationSection
                CompetenceLevelPill(
                    previous: previousCompetenceLevel,
                    current: currentCompetenceLevel,
                    topic: question.topic
                )
                continueButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
        }
        .background(Color.black.ignoresSafeArea())
        .task {
            guard !wasCorrect else { return }
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                isExplanationExpanded = true
            }
        }
    }

    private var resultHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(accentColor)
                .accessibilityHidden(true)
            Text(RevealCopy.header(wasCorrect: wasCorrect, missDistance: missDistance))
                .font(.title2.bold())
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            wasCorrect
                ? "Richtig beantwortet. \(RevealCopy.header(wasCorrect: true, missDistance: missDistance))"
                : "Falsch beantwortet. \(RevealCopy.header(wasCorrect: false, missDistance: missDistance))"
        )
        .accessibilityAddTraits(.isHeader)
    }

    private var correctAnswerCard: some View {
        HStack(alignment: .top, spacing: 14) {
            DirectionalArrow(direction: correctOption.swipeDirection, color: accentColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Richtige Antwort")
                    .font(.caption)
                    .foregroundStyle(Color(white: 0.65))
                Text(correctOption.text)
                    .font(.body)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "checkmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(accentColor)
                .accessibilityHidden(true)
        }
        .padding(16)
        .background(accentColor.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(accentColor.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Richtige Antwort: \(correctOption.text). "
            + "Wischrichtung: \(correctOption.swipeDirection.spatialHintLabel)"
        )
    }

    private var wrongDirectionRow: some View {
        HStack(spacing: 16) {
            DirectionalArrow(
                direction: selectedDirection,
                color: Color(red: 1.0, green: 0.27, blue: 0.27),
                strikethrough: true
            )
            .accessibilityHidden(true)

            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            DirectionalArrow(
                direction: correctOption.swipeDirection,
                color: .green
            )
            .accessibilityHidden(true)

            Text("Richtige Richtung")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Falsche Richtung gewischt. "
            + "Richtig wäre: \(correctOption.swipeDirection.spatialHintLabel)"
        )
    }

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    isExplanationExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
                        .accessibilityHidden(true)
                    Text(RevealCopy.explanationPrefix(wasCorrect: wasCorrect))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: isExplanationExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityLabel(
                isExplanationExpanded ? "Erklärung ausblenden" : "Erklärung anzeigen"
            )
            .accessibilityHint(
                isExplanationExpanded
                    ? "Schließt die Erklärung"
                    : "Zeigt die vollständige Erklärung an"
            )

            if isExplanationExpanded {
                Text(question.explanation)
                    .font(.body)
                    .foregroundStyle(Color(white: 0.85))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .opacity.combined(with: .move(edge: .top))
                    )
                    .accessibilityLabel("Erklärung: \(question.explanation)")
            }
        }
        .padding(16)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var continueButton: some View {
        Button(action: onContinue) {
            Text(continueLabel)
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityLabel(continueLabel)
        .padding(.top, 8)
    }
}

// MARK: - DirectionalArrow

private struct DirectionalArrow: View {

    let direction: SwipeDirection
    var color: Color
    var strikethrough: Bool = false

    private var symbolName: String {
        switch direction {
        case .right: "arrow.right"
        case .left:  "arrow.left"
        case .up:    "arrow.up"
        case .down:  "arrow.down"
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)
            Image(systemName: symbolName)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
            if strikethrough {
                Rectangle()
                    .fill(color.opacity(0.85))
                    .frame(width: 2, height: 36)
                    .rotationEffect(.degrees(45))
                    .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - CompetenceLevelPill

struct CompetenceLevelPill: View {

    let previous: CompetenceLevel
    let current: CompetenceLevel
    let topic: TopicArea

    private var levelChanged: Bool { previous != current }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: topic.symbolName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text(topic.displayName)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            if levelChanged {
                HStack(spacing: 6) {
                    levelChip(previous, dimmed: true)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    levelChip(current, dimmed: false)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "Lernstand \(topic.displayName): "
                    + "\(previous.localizedName) zu \(current.localizedName)"
                )
            } else {
                levelChip(current, dimmed: false)
                    .accessibilityLabel(
                        "Lernstand \(topic.displayName): \(current.localizedName)"
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func levelChip(_ level: CompetenceLevel, dimmed: Bool) -> some View {
        Text(level.localizedName)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(dimmed ? Color(white: 0.5) : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(level.fillColor.opacity(dimmed ? 0.3 : 0.8))
            )
    }
}