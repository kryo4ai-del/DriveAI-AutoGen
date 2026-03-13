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

struct RootView: View {

    @ObservedObject var competenceService: TopicCompetenceService

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack {
                    HomeView(competenceService: competenceService)
                }
            }

            Tab("Lernstand", systemImage: "chart.bar.fill") {
                NavigationStack {
                    SkillMapView(
                        viewModel: SkillMapViewModel(service: competenceService)
                    )
                }
            }

            Tab("Generalprobe", systemImage: "doc.text.magnifyingglass") {
                NavigationStack {
                    ExamSimulationView(
                        simulationService: StubExamSimulationService(),
                        readinessService: StubReadinessScoreService()
                    )
                }
            }

            Tab("Verlauf", systemImage: "clock.arrow.circlepath") {
                NavigationStack {
                    ExamHistoryView(
                        history: [],
                        onSelectResult: { _ in }
                    )
                }
            }
        }
        .tint(.green)
    }
}
