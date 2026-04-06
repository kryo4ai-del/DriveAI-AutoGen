// DriveAI/Features/GrowthTracking/Views/GrowthDashboardView.swift
import SwiftUI

struct GrowthDashboardView: View {
    @StateObject var viewModel: GrowthTrackingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Readiness Score
                ReadinessScoreCard(score: viewModel.readinessScore, message: viewModel.motivationalMessage)
                    .padding(.horizontal)

                // Primary Weakness
                if let weakness = viewModel.primaryWeakness {
                    PrimaryWeaknessCard(weakness: weakness)
                        .padding(.horizontal)
                } else if viewModel.isLoading {
                    ProgressView("Analysiere deine Fortschritte...")
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    EmptyStateView(
                        title: "Noch keine Daten",
                        message: "Fang an zu lernen und deine Schwachstellen werden hier angezeigt!",
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                }

                // Performance Trend
                PerformanceSparklineChart(data: viewModel.performanceTrend)
                    .padding(.horizontal)

                // All Weaknesses
                if !viewModel.allWeaknesses.isEmpty {
                    WeaknessesGrid(weaknesses: viewModel.allWeaknesses)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Mein Lernfortschritt")
        .task {
            await viewModel.refresh()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
