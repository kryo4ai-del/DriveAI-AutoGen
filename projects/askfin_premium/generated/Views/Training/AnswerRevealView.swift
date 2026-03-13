// Views/Training/AnswerRevealView.swift

import SwiftUI

struct AnswerRevealView: View {

    let question: SessionQuestion
    let wasCorrect: Bool
    let missDistance: Int
    let onContinue: () -> Void

    @State private var explanationVisible = false
    @AccessibilityFocusState private var explanationFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                resultHeader
                correctAnswerRow
                explanationSection
                continueButton
            }
            .padding(24)
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            announceResult()
            showExplanationAfterDelay()
        }
    }

    // MARK: - Subviews

    private var resultHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(wasCorrect ? .green : .red)

            VStack(alignment: .leading, spacing: 2) {
                Text(RevealCopy.header(wasCorrect: wasCorrect, missDistance: missDistance))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(question.topic.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        // Redundant non-color signal: icon + text label (audit Finding 4).
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(wasCorrect ? "Richtig" : "Falsch")
    }

    private var correctAnswerRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Richtige Antwort")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                Text(question.correctOption.swipeDirection.answerLetter)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.green))

                Text(question.correctOption.text)
                    .font(.body)
                    .foregroundColor(.white)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.green.opacity(0.1))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Richtige Antwort: \(question.correctOption.swipeDirection.answerLetter), "
            + question.correctOption.text
        )
    }

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(RevealCopy.explanationPrefix(wasCorrect: wasCorrect))
                .font(.caption)
                .foregroundColor(.secondary)

            Text(question.explanation)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                // Progressive disclosure — fades in after brief delay.
                .opacity(explanationVisible ? 1 : 0)
                .animation(
                    reduceMotion ? .none : .easeIn(duration: 0.3),
                    value: explanationVisible
                )
                // VoiceOver focus moves here on reveal (audit Finding 5).
                .accessibilityFoc

[reviewer]
## DriveAI Training Mode — Code Review

The view layer is finally present. The structural quality is good. There are real issues that must be fixed before this compiles and behaves correctly.

---

## Critical Issues

### 1. `AnswerRevealView` is cut off mid-implementation — again

The file ends at:
