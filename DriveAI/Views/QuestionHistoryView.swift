import SwiftUI

struct QuestionHistoryView: View {
    @StateObject private var viewModel = QuestionHistoryViewModel()
    @State private var showClearConfirm = false

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Filter picker
            Picker("Filter", selection: $viewModel.filter) {
                Text("All").tag(QuestionHistoryViewModel.HistoryFilter.all)
                Text("Correct").tag(QuestionHistoryViewModel.HistoryFilter.correct)
                Text("Incorrect").tag(QuestionHistoryViewModel.HistoryFilter.incorrect)
            }
            .pickerStyle(.segmented)
            .padding()

            if viewModel.filteredEntries.isEmpty {
                Spacer()
                Text("No history yet.")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List(viewModel.filteredEntries) { entry in
                    historyRow(entry)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Question History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Clear") { showClearConfirm = true }
                    .foregroundColor(.red)
                    .disabled(viewModel.entries.isEmpty)
            }
        }
        .alert("Clear History?", isPresented: $showClearConfirm) {
            Button("Clear", role: .destructive) { viewModel.clearHistory() }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear { viewModel.load() }
    }

    @ViewBuilder
    private func historyRow(_ entry: QuestionHistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: entry.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(entry.isCorrect ? .green : .red)
                Text(entry.questionText)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(2)
                Spacer()
                Text(dateFormatter.string(from: entry.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Answer").font(.caption).foregroundColor(.secondary)
                    Text(entry.userAnswer).font(.caption).foregroundColor(entry.isCorrect ? .green : .red)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Correct").font(.caption).foregroundColor(.secondary)
                    Text(entry.correctAnswer).font(.caption).foregroundColor(.green)
                }
                if entry.confidenceScore > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Confidence").font(.caption).foregroundColor(.secondary)
                        Text("\(entry.confidenceLabel) (\(Int(entry.confidenceScore * 100))%)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
