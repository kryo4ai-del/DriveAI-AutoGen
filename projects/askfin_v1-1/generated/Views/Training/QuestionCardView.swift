// Views/Training/QuestionCardView.swift

import SwiftUI

struct QuestionCardView: View {

    let question: SessionQuestion
    let optionsRevealed: Bool
    let onSwipe: (SwipeDirection) -> Void
    let onRevealTap: () -> Void

    @State private var dragOffset: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Threshold in points before a swipe registers.
    private let swipeThreshold: CGFloat = 60

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            microLabel
            questionText
            Divider().background(Color.white.opacity(0.15))
            answerOptions
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .offset(reduceMotion ? .zero : dragOffset)
        .gesture(swipeGesture)
    }

    // MARK: - Subviews

    private var microLabel: some View {
        Text(question.questionType.microLabel(for: question.topic))
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.green)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.15))
            .clipShape(Capsule())
            // Semantic header so VoiceOver announces it before the question body.
            .accessibilityAddTraits(.isHeader)
    }

    private var questionText: some View {
        // Group micro-label + question as one accessibility element (Issue 3 from audit).
        VStack(alignment: .leading, spacing: 12) {
            Text(question.text)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(question.questionType.microLabel(for: question.topic)). \(question.text)"
        )
    }

    private var answerOptions: some View {
        VStack(spacing: 12) {
            if optionsRevealed {
                ForEach(question.options) { option in
                    answerButton(for: option)
                }
            } else {
                revealPrompt
            }
        }
    }

    private func answerButton(for option: AnswerOption) -> some View {
        Button {
            onSwipe(option.swipeDirection)
        } label: {
            HStack(spacing: 12) {
                // Spatial hint — hidden from VoiceOver (audit Finding 2).
                Text(option.swipeDirection.spatialHintLabel)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .frame(width: 32)
                    .accessibilityHidden(true)

                Text(option.text)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.07))
            )
        }
        // Parallel accessible path alongside swipe gesture (audit Finding 1).
        .contentShape(Rectangle())
        .frame(minHeight: 44)
        .accessibilityLabel("Antwort \(option.swipeDirection.answerLetter): \(option.text)")
        .accessibilityHint("Tippen zum Auswählen")
        .accessibilityAddTraits(.isButton)
    }

    private var revealPrompt: some View {
        Button {
            onRevealTap()
        } label: {
            HStack {
                Image(systemName: "eye")
                Text("Antworten anzeigen")
            }
            .font(.body)
            .foregroundColor(.green)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .accessibilityLabel("Antworten anzeigen")
        .accessibilityHint("Tippen um die Antwortmöglichkeiten zu sehen")
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                guard !reduceMotion else { return }
                dragOffset = value.translation
            }
            .onEnded { value in
                dragOffset = .zero
                guard optionsRevealed else {
                    onRevealTap()
                    return
                }
                if let direction = resolvedDirection(from: value.translation) {
                    onSwipe(direction)
                }
            }
    }

    private func resolvedDirection(from translation: CGSize) -> SwipeDirection? {
        let x = translation.width
        let y = translation.height
        guard max(abs(x), abs(y)) >= swipeThreshold else { return nil }

        // Dominant axis determines direction.
        if abs(x) > abs(y) {
            return x > 0 ? .right : .left
        } else {
            return y < 0 ? .up : .down
        }
    }
}