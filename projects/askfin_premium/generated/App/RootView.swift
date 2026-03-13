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
            NavigationStack {
                HomeView(competenceService: competenceService)
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
                    simulationService: StubExamSimulationService(),
                    readinessService: StubReadinessScoreService()
                )
            }
            .tabItem { Label("Generalprobe", systemImage: "doc.text.magnifyingglass") }

            NavigationStack {
                ExamHistoryView(
                    history: [],
                    onSelectResult: { _ in }
                )
            }
            .tabItem { Label("Verlauf", systemImage: "clock.arrow.circlepath") }
        }
        .tint(.green)
    }
}
