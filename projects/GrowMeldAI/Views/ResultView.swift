// Views/Screens/ResultView.swift
import SwiftUI

struct ResultView: View {
    let score: Int
    let totalQuestions: Int
    let passed: Bool

    @State private var showExplanation = false
    @Environment(\.navigate) private var navigate

    private var feedbackText: String {
        let percentage = Double(score) / Double(totalQuestions) * 100
        let categoryAccuracy = calculateCategoryAccuracy()

        if passed {
            return String(
                format: NSLocalizedString(
                    "Du bist bereit! %d/%d in %@ — nur noch %d Fragen bis zur Prüfung.",
                    comment: "Positive feedback with category breakdown"
                ),
                score,
                totalQuestions,
                categoryAccuracy,
                max(0, 10 - score)
            )
        } else {
            return String(
                format: NSLocalizedString(
                    "Fast geschafft! %d/%d in %@ — %d%% richtig. Übe weiter!",
                    comment: "Encouraging feedback with accuracy"
                ),
                score,
                totalQuestions,
                categoryAccuracy,
                Int(percentage)
            )
        }
    }

    private func calculateCategoryAccuracy() -> String {
        // In a real app, this would come from AppState
        return "Vorfahrt"
    }

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: passed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(passed ? .green : .orange)

                Text(feedbackText)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("\(score)/\(totalQuestions)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }

            if showExplanation {
                VStack(spacing: 16) {
                    Text("Auswertung:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Add detailed breakdown here
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Button(action: {
                navigate(.home)
            }) {
                Text("Zurück zum Lernen")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .navigationTitle("Prüfungsergebnis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Details") {
                    withAnimation {
                        showExplanation.toggle()
                    }
                }
            }
        }
    }
}