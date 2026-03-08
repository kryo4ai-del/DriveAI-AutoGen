import SwiftUI

struct TrafficSignHistoryView: View {
    @StateObject private var viewModel = TrafficSignHistoryViewModel()
    @State private var showClearConfirm = false

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.entries.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No traffic sign history yet.")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List(viewModel.entries) { entry in
                    NavigationLink(destination: TrafficSignHistoryDetailView(entry: entry)) {
                        signRow(entry)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Traffic Sign History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Clear") { showClearConfirm = true }
                    .foregroundColor(.red)
                    .disabled(viewModel.entries.isEmpty)
            }
        }
        .alert("Clear Sign History?", isPresented: $showClearConfirm) {
            Button("Clear", role: .destructive) { viewModel.clearHistory() }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear { viewModel.load() }
    }

    @ViewBuilder
    private func signRow(_ entry: TrafficSignHistoryEntry) -> some View {
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
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.signName)
                        .font(.subheadline)
                        .bold()
                        .lineLimit(1)
                    Spacer()
                    Text(dateFormatter.string(from: entry.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    categoryBadge(entry.signCategory)
                    Text("\(entry.confidenceLabel) (\(entry.confidencePercentage)%)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func categoryBadge(_ category: TrafficSignCategory) -> some View {
        Text(category.rawValue)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(categoryColor(category).opacity(0.15))
            .foregroundColor(categoryColor(category))
            .cornerRadius(4)
    }

    private func categoryColor(_ category: TrafficSignCategory) -> Color {
        switch category {
        case .prohibitory:   return .red
        case .mandatory:     return .blue
        case .warning:       return .orange
        case .priority:      return .yellow
        case .informational: return .green
        case .unknown:       return .gray
        }
    }
}
