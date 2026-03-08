import SwiftUI

struct AnalysisDebugPanel: View {
    @StateObject private var viewModel = AnalysisDebugPanelViewModel()

    // Optional: inject confidence for display
    var confidence: AnswerConfidence?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Confidence section (shown when available)
                if let confidence = confidence {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Answer Confidence")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 12)

                        HStack {
                            Text("\(confidence.label) (\(confidence.percentage)%)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(confidenceColor(for: confidence.score))
                                    .frame(width: geo.size.width * confidence.score, height: 8)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                    Divider()
                }

                // Debug log list
                Text("Analysis Debug Panel")
                    .font(.title3)
                    .bold()
                    .padding([.horizontal, .top])

                List(viewModel.debugLogs) { log in
                    HStack {
                        Text(log.timestamp, formatter: dateFormatter)
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text(log.message)
                            .font(.body)
                            .foregroundColor(log.level == .error ? .red : .black)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Debug Info", displayMode: .inline)
        }
    }

    private func confidenceColor(for score: Double) -> Color {
        switch score {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }
}
