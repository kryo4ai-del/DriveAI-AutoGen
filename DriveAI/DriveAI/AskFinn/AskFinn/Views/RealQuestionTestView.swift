import SwiftUI
import PhotosUI
import UIKit

struct RealQuestionTestView: View {
    @StateObject private var viewModel = RealQuestionTestViewModel()
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Import button
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Import Screenshot", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        guard let item = newItem,
                              let data = try? await item.loadTransferable(type: Data.self),
                              let uiImage = UIImage(data: data) else { return }
                        viewModel.runPipeline(image: uiImage)
                    }
                }

                // Status
                statusBadge

                // Image preview
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(10)
                }

                // Pipeline results
                if let ocr = viewModel.ocrText {
                    debugSection("OCR Text", icon: "doc.text.magnifyingglass") {
                        Text("\(ocr.count) chars, \(ocr.components(separatedBy: "\n").filter { !$0.isEmpty }.count) lines")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(ocr)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }

                if viewModel.parsedQuestion != nil {
                    debugSection("Parsed Question", icon: "questionmark.circle") {
                        Text(viewModel.parsedQuestion ?? "")
                            .font(.caption)
                            .bold()
                    }
                }

                if !viewModel.detectedAnswers.isEmpty {
                    debugSection("Detected Answers (\(viewModel.detectedAnswers.count))", icon: "list.number") {
                        ForEach(Array(viewModel.detectedAnswers.enumerated()), id: \.offset) { index, answer in
                            HStack(alignment: .top, spacing: 6) {
                                Text("\(index + 1).")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 16, alignment: .trailing)
                                Text(answer)
                                    .font(.caption)
                            }
                        }
                    }
                }

                if viewModel.detectedCategory != nil {
                    debugSection("Category Detection", icon: "tag.fill") {
                        HStack(spacing: 8) {
                            Text(viewModel.detectedCategory ?? "")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(6)

                            if viewModel.categoryConfidence > 0 {
                                Text("\(Int(viewModel.categoryConfidence * 100))% confidence")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if !viewModel.matchedKeywords.isEmpty {
                            HStack(spacing: 4) {
                                Text("Keywords:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(viewModel.matchedKeywords.joined(separator: ", "))
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }

                if viewModel.solverPrediction != nil {
                    debugSection("Solver Output", icon: "brain") {
                        HStack {
                            Text("Prediction:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(viewModel.solverPrediction ?? "")
                                .font(.caption)
                                .bold()
                        }

                        if viewModel.solverConfidence > 0 {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Confidence:")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("\(Int(viewModel.solverConfidence * 100))%")
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(confidenceColor(viewModel.solverConfidence))
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 6)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(confidenceColor(viewModel.solverConfidence))
                                            .frame(width: geo.size.width * viewModel.solverConfidence, height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                        }

                        if let explanation = viewModel.solverExplanation, !explanation.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Explanation:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(explanation)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Real Question Test")
    }

    // MARK: - Status badge

    @ViewBuilder
    private var statusBadge: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .running(let step):
            HStack(spacing: 8) {
                ProgressView()
                Text(step)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        case .done:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Pipeline complete")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        case .error(let msg):
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text(msg)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Debug section card

    private func debugSection<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.subheadline)
                    .bold()
            }
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private func confidenceColor(_ score: Double) -> Color {
        switch score {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }
}
