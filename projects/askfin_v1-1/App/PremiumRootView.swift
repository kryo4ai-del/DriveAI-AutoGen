// RootView.swift
// Root navigation shell for AskFin Premium.
//
// TabView with 4 tabs matching the premium pillars:
//   1. Home — daily training entry + readiness at a glance
//   2. Lernstand — Skill Map (topic competence grid)
//   3. Generalprobe — Exam Simulation
//   4. Fortschritt — Exam History + Readiness detail
//
// Dark theme enforced at app level. Green accent throughout.

import SwiftUI

struct PremiumRootView: View {

    @ObservedObject var competenceService: TopicCompetenceService
    @ObservedObject var historyStore: SessionHistoryStore
    @State private var selectedResult: SimulationResult?

    var body: some View {
        TabView {
            NavigationStack {
                PremiumHomeView(competenceService: competenceService)
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                SkillMapView(
                    viewModel: SkillMapViewModel(service: competenceService)
                )
            }
            .tabItem { Label("Lernstand", systemImage: "chart.bar.fill") }

            NavigationStack {
                ExamSimulationView(
                    simulationService: StubExamSimulationService(historyStore: historyStore),
                    readinessService: StubReadinessScoreService()
                )
            }
            .tabItem { Label("Generalprobe", systemImage: "doc.text.magnifyingglass") }

            NavigationStack {
                ExamHistoryView(
                    history: historyStore.results,
                    onSelectResult: { result in selectedResult = result }
                )
            }
                .sheet(item: $selectedResult) { result in
                    NavigationStack {
                        SimulationResultView(
                            result: result,
                            readinessScore: nil,
                            onRetry: { selectedResult = nil },
                            onDismiss: { selectedResult = nil }
                        )
                    }
                }
            .tabItem { Label("Verlauf", systemImage: "clock.arrow.circlepath") }
        }
        .tint(.green)
    }
}
