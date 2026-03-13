// TopicDetailView.swift
// Detail view for a single TopicArea.
//
// Shows:
// - Competence level with visual indicator
// - Accuracy stats (total, correct, weighted)
// - Recent performance trend
// - Spacing queue status (due items for this topic)
// - CTA to start focused training
//
// Reached from: SkillMapView topic tap, TopicPickerView

import SwiftUI

struct TopicDetailView: View {

    let topic: TopicArea
    @ObservedObject var competenceService: TopicCompetenceService
    let onStartTraining: (TopicArea) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                topicHeader
                Divider().background(Color(.systemGray3)).padding(.horizontal, 20)
                competenceSection
                statsSection
                spacingSection
                startTrainingButton
            }
            .padding(.vertical, 24)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(topic.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var topicHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(competence.competenceLevel.fillColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: topic.symbolName)
                    .font(.system(size: 36))
                    .foregroundColor(competence.competenceLevel.fillColor)
            }

            Text(topic.displayName)
                .font(.title2.weight(.bold))
                .foregroundColor(.white)

            Text(competence.competenceLevel.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(competence.competenceLevel.fillColor)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(topic.displayName), \(competence.competenceLevel.displayName)")
    }

    // MARK: - Competence Visual

    private var competenceSection: some View {
        VStack(spacing: 12) {
            competenceBar

            HStack {
                ForEach(CompetenceLevel.allCases, id: \.rawValue) { level in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(level == competence.competenceLevel ? level.fillColor : Color(.systemGray5))
                            .frame(width: 10, height: 10)
                        Text(level.displayName)
                            .font(.system(size: 9))
                            .foregroundColor(level == competence.competenceLevel ? .white : .secondary)
                    }
                    if level != CompetenceLevel.allCases.last {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var competenceBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 4)
                    .fill(competence.competenceLevel.fillColor)
                    .frame(width: max(0, geo.size.width * competence.weightedAccuracy), height: 8)
                    .animation(.easeInOut(duration: 0.4), value: competence.weightedAccuracy)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 20)
        .accessibilityLabel("Genauigkeit: \(Int(competence.weightedAccuracy * 100)) Prozent")
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(spacing: 12) {
            Text("Statistik")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(title: "Gesamt", value: "\(competence.totalAnswers)", subtitle: "Antworten")
                statCard(title: "Richtig", value: "\(competence.correctAnswers)", subtitle: "von \(competence.totalAnswers)")
                statCard(
                    title: "Genauigkeit",
                    value: "\(Int(competence.rawAccuracy * 100))%",
                    subtitle: "ungewichtet"
                )
                statCard(
                    title: "Gewichtet",
                    value: "\(Int(competence.weightedAccuracy * 100))%",
                    subtitle: "aktuelle Stärke"
                )
            }
            .padding(.horizontal, 20)
        }
    }

    private func statCard(title: String, value: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(white: 0.12))
        .cornerRadius(10)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Spacing Queue

    private var spacingSection: some View {
        let dueCount = spacingDueCount

        return VStack(spacing: 8) {
            Text("Wiederholung")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            HStack(spacing: 12) {
                Image(systemName: dueCount > 0 ? "clock.badge.exclamationmark" : "checkmark.circle")
                    .font(.title3)
                    .foregroundColor(dueCount > 0 ? .orange : .green)

                VStack(alignment: .leading, spacing: 2) {
                    if dueCount > 0 {
                        Text("\(dueCount) Frage\(dueCount == 1 ? "" : "n") fällig")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white)
                        Text("Wiederholung steht an — ideal jetzt trainieren.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Alles auf dem neuesten Stand")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white)
                        Text("Keine Wiederholungen fällig.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(white: 0.12))
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Training CTA

    private var startTrainingButton: some View {
        Button(action: { onStartTraining(topic) }) {
            HStack {
                Image(systemName: "play.fill")
                Text("\(topic.displayName) trainieren")
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.green)
            .cornerRadius(14)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .accessibilityHint("Startet eine fokussierte Trainingseinheit für \(topic.displayName)")
    }

    // MARK: - Data

    private var competence: TopicCompetence {
        competenceService.competenceMap[topic.rawValue]
            ?? TopicCompetence(topic: topic)
    }

    private var spacingDueCount: Int {
        competenceService.spacingDueItems()
            .filter { $0.topic == topic }
            .count
    }
}
