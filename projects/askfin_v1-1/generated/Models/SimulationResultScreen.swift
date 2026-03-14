import SwiftUI

struct SimulationResultScreen: View {
    @StateObject private var viewModel: SimulationResultViewModel
    @Environment(\.dismiss) var dismiss
    
    init(
        result: SimulationResult,
        statisticsService: StatisticsService
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
                    ResultHeader(result: viewModel.result)
                    
                    ReadinessGaugeView(readiness: viewModel.readiness)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kategorieergebnisse")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.categorysSortedByWeakness(), id: \.categoryId) { score in
                            CategoryPerformanceRow(score: score)
                        }
                    }
                    
                    if !viewModel.readiness.categoryWeaknesses.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Zum Üben empfohlen", systemImage: "target")
                                .font(.subheadline.bold())
                            
                            Text(viewModel.readiness.categoryWeaknesses.joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    ActionButtonGroup(result: viewModel.result)
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Ergebnisse")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}