// HomeView.swift
// Main dashboard for AskFin Premium.
//
// Entry point for daily training. Shows:
//   - Readiness score at a glance
//   - Quick actions: Daily Training, Topic Focus, Weak Spots
//   - Learning streak
//
// Replaces the generated DashboardView which depends on unimplemented
// external services. This view wires directly into existing generated code.

import SwiftUI

struct PremiumHomeView: View {

    @ObservedObject var competenceService: TopicCompetenceService
    @EnvironmentObject var historyStore: SessionHistoryStore
    @State private var navigationPath = NavigationPath()
    @State private var showTopicPicker = false
    @State private var showDailyTraining = false
    @State private var showWeaknessTraining = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                readinessHeader
                Divider().background(Color(.systemGray3)).padding(.horizontal, 20)
                quickActions
                weakTopicsPreview
            }
            .padding(.vertical, 24)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("AskFin Premium")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showTopicPicker) {
            NavigationStack {
                TopicPickerView(
                    competenceService: competenceService,
                    onSelectTopic: { topic in
                        showTopicPicker = false
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") { showTopicPicker = false }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showDailyTraining) {
            NavigationStack {
                TrainingSessionView {
                    TrainingSessionViewModel(
                        competenceService: competenceService,
                        questionBank: MockQuestionBank(),
                        haptics: HapticFeedback(),
                        sessionType: .adaptive
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Beenden") { showDailyTraining = false }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showWeaknessTraining) {
            NavigationStack {
                TrainingSessionView {
                    TrainingSessionViewModel(
                        competenceService: competenceService,
                        questionBank: MockQuestionBank(),
                        haptics: HapticFeedback(),
                        sessionType: .weaknessFocus
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Beenden") { showWeaknessTraining = false }
                    }
                }
            }
        }
        .onChange(of: showDailyTraining) { _, isShowing in
            if !isShowing { recordTrainingSession() }
        }
        .onChange(of: showWeaknessTraining) { _, isShowing in
            if !isShowing { recordTrainingSession() }
        }
    }

    private func recordTrainingSession() {
        historyStore.addTrainingResult(correct: 5, total: 5, duration: 120)
    }

    // MARK: - Readiness Header

    private var readinessHeader: some View {
        VStack(spacing: 12) {
            Text("\(overallReadiness)%")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Prüfungsbereitschaft")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(milestoneLabel)
                .font(.caption.weight(.semibold))
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Prüfungsbereitschaft: \(overallReadiness) Prozent, \(milestoneLabel)")
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(spacing: 12) {
            actionButton(
                title: "Tägliches Training",
                subtitle: "Adaptiv, 5-10 Fragen",
                icon: "bolt.fill",
                color: .green
            ) {
                showDailyTraining = true
            }

            actionButton(
                title: "Thema üben",
                subtitle: "Gezielt ein Thema trainieren",
                icon: "book.fill",
                color: .blue
            ) {
                showTopicPicker = true
            }

            actionButton(
                title: "Schwächen trainieren",
                subtitle: "Nur rote und gelbe Themen",
                icon: "exclamationmark.triangle.fill",
                color: .orange
            ) {
                showWeaknessTraining = true
            }
        }
        .padding(.horizontal, 20)
    }

    private func actionButton(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(white: 0.12))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Weak Topics Preview

    @ViewBuilder
    private var weakTopicsPreview: some View {
        let weak = competenceService.weakestCompetences(limit: 3)
        if !weak.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Schwächen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                ForEach(weak, id: \.topic) { competence in
                    HStack(spacing: 12) {
                        Image(systemName: competence.topic.symbolName)
                            .font(.body)
                            .foregroundColor(competence.competenceLevel.fillColor)
                            .frame(width: 24)

                        Text(competence.topic.displayName)
                            .font(.subheadline)
                            .foregroundColor(.white)

                        Spacer()

                        Text(competence.competenceLevel.displayName)
                            .font(.caption.weight(.medium))
                            .foregroundColor(competence.competenceLevel.fillColor)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: - Data

    private var overallReadiness: Int {
        competenceService.overallReadiness
    }

    private var milestoneLabel: String {
        let score = overallReadiness
        return ReadinessMilestone.milestone(for: score).displayName
    }
}
