import SwiftUI

struct SimulationResultScreen: View {
    @StateObject private var viewModel: SimulationResultViewModel
    @Environment(\.dismiss) var dismiss
    
    init(
        result: SimulationResult,
        statisticsService: StatisticsService = .shared
    ) {
        _viewModel = StateObject(
            wrappedValue: SimulationResultViewModel(
                result: result,
                statisticsService: statisticsService
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Result Header
                    ResultHeader(result: viewModel.result)
                    
                    // Readiness Gauge
                    ReadinessGaugeView(readiness: viewModel.readiness)
                    
                    // Category Breakdown Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kategorieergebnisse")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        
                        ForEach(viewModel.categorysSortedByWeakness(), id: \.id) { score in
                            CategoryPerformanceRow(score: score)
                        }
                    }
                    
                    // Weaknesses Alert (if any)
                    if !viewModel.readiness.categoryWeaknesses.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "target")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.orange)
                                
                                Text("Zum Üben empfohlen")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                            }
                            
                            Text(viewModel.readiness.categoryWeaknesses.joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                    
                    // Action Buttons
                    ActionButtonGroup(result: viewModel.result)
                    
                    // Spacer
                    Spacer(minLength: 24)
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Ergebnisse")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .top) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Ein unbekannter Fehler ist aufgetreten.")
            }
        }
    }
}

#Preview {
    SimulationResultScreen(
        result: .previewPass,
        statisticsService: StatisticsService()
    )
}

#Preview("Nicht bestanden") {
    SimulationResultScreen(
        result: .previewFail,
        statisticsService: StatisticsService()
    )
}