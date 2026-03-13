// TopicPickerView.swift
// Topic selection for focused training sessions.
//
// Shows all 16 TopicArea entries grouped by domain with competence colors.
// Weakest topics are visually highlighted to guide the learner toward gaps.
// Tapping a topic starts a focused TrainingSession for that topic.
//
// Entry point: HomeDashboard -> "Thema üben" -> TopicPickerView

import SwiftUI

struct TopicPickerView: View {

    @ObservedObject var competenceService: TopicCompetenceService
    let onSelectTopic: (TopicArea) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                if !weakestTopics.isEmpty {
                    weaknessSection
                }
                allTopicsSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Thema wählen")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welches Thema möchtest du üben?")
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
            Text("Wähle ein Thema für eine gezielte Trainingseinheit.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Weakness Highlight

    private var weaknessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                Text("Schwächen zuerst")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
            }

            ForEach(weakestTopics, id: \.topic) { competence in
                topicRow(competence: competence, isWeak: true)
            }
        }
    }

    // MARK: - All Topics

    private var allTopicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(TopicDomain.allCases, id: \.self) { domain in
                domainGroup(domain)
            }
        }
    }

    private func domainGroup(_ domain: TopicDomain) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(domain.displayName)
                .font(.headline)
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(domain.topics, id: \.self) { topic in
                    topicCard(topic)
                }
            }
        }
    }

    private func topicCard(_ topic: TopicArea) -> some View {
        let competence = competenceFor(topic)
        let level = competence.competenceLevel

        return Button(action: { onSelectTopic(topic) }) {
            VStack(spacing: 6) {
                Image(systemName: topic.symbolName)
                    .font(.title3)
                    .foregroundColor(level.fillColor)

                Text(topic.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(level.displayName)
                    .font(.caption2)
                    .foregroundColor(level.fillColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(white: 0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(level.fillColor, lineWidth: 1.5)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(topic.displayName), \(level.displayName)")
        .accessibilityHint("Startet fokussiertes Training für \(topic.displayName)")
    }

    private func topicRow(competence: TopicCompetence, isWeak: Bool) -> some View {
        Button(action: { onSelectTopic(competence.topic) }) {
            HStack(spacing: 12) {
                Image(systemName: competence.topic.symbolName)
                    .font(.title3)
                    .foregroundColor(competence.competenceLevel.fillColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(competence.topic.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                    Text("\(competence.correctAnswers)/\(competence.totalAnswers) richtig")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(white: 0.12))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(competence.topic.displayName), \(competence.competenceLevel.displayName)")
        .accessibilityHint("Startet fokussiertes Training")
    }

    // MARK: - Data

    private var weakestTopics: [TopicCompetence] {
        competenceService.weakestCompetences(limit: 3)
    }

    private func competenceFor(_ topic: TopicArea) -> TopicCompetence {
        competenceService.competenceMap[topic.rawValue]
            ?? TopicCompetence(topic: topic)
    }
}
