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
                    NavigationLink(destination: QuestionHistoryDetailView(entry: entry)) {
                        historyRow(entry)
                    }
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
        HStack(alignment: .top, spacing: 10) {
            // Thumbnail
            if let data = entry.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .cornerRadius(8)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: entry.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(entry.isCorrect ? .green : .red)
                        .font(.caption)
                    Text(entry.questionText)
                        .font(.subheadline)
                        .bold()
                        .lineLimit(2)
                    Spacer()
                    Text(dateFormatter.string(from: entry.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Your Answer").font(.caption2).foregroundColor(.secondary)
                        Text(entry.userAnswer).font(.caption).foregroundColor(entry.isCorrect ? .green : .red)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Correct").font(.caption2).foregroundColor(.secondary)
                        Text(entry.correctAnswer).font(.caption).foregroundColor(.green)
                    }
                    if entry.confidenceScore > 0 {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Confidence").font(.caption2).foregroundColor(.secondary)
                            Text("\(entry.confidenceLabel) (\(Int(entry.confidenceScore * 100))%)")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
