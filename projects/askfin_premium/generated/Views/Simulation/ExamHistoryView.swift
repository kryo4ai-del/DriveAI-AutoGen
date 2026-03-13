// ExamHistoryView.swift
// Chronological list of past simulation attempts.
//
// Each entry shows: date, Fehlerpunkte, pass/fail, time taken.
// Tappable rows open full SimulationResultView for that attempt.
//
// Empty state: encouraging message, not a blank screen.

import SwiftUI

struct ExamHistoryView: View {

    let history: [SimulationResult]
    let onSelectResult: (SimulationResult) -> Void

    var body: some View {
        Group {
            if history.isEmpty {
                emptyState
            } else {
                historyList
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Deine Simulationen")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Noch keine Simulationen")
                .font(.headline)
                .foregroundColor(.white)
            Text("Starte deine erste Generalprobe, um deinen Fortschritt zu sehen.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - History List

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(history) { result in
                    Button(action: { onSelectResult(result) }) {
                        historyRow(result)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accessibilityLabel(for: result))
                }
            }
            .padding(20)
        }
    }

    private func historyRow(_ result: SimulationResult) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate(result.completedAt))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                Text(formattedTime(result.timeTaken))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Text("\(result.totalFehlerpunkte) FP")
                    .font(.headline.monospacedDigit())
                    .foregroundColor(result.passed ? .green : .orange)

                Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.passed ? .green : .orange)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(10)
    }

    // MARK: - Formatting

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return "\(String(format: "%d:%02d", minutes, seconds)) min"
    }

    private func accessibilityLabel(for result: SimulationResult) -> String {
        let status = result.passed ? "bestanden" : "nicht bestanden"
        return "\(formattedDate(result.completedAt)), \(result.totalFehlerpunkte) Fehlerpunkte, \(status)"
    }
}
