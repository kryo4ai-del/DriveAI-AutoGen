// ViewModels/SkillMapViewModel.swift

import Foundation
import Combine

@MainActor
final class SkillMapViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var competences: [TopicArea: TopicCompetence] = [:]
    @Published private(set) var overallReadinessScore: Double = 0.0
    @Published private(set) var projectedReadinessDelta: Double = 0.0

    // MARK: - Computed

    var domainSections: [DomainSection] {
        TopicDomain.allCases.map { domain in
            DomainSection(
                domain: domain,
                competences: domain.topics.compactMap { competences[$0] }
            )
        }
    }

    /// Formatted readiness percentage for display, e.g. "67%".
    var readinessLabel: String {
        "\(Int(overallReadinessScore * 100))%"
    }

    /// Formatted projected delta, e.g. "+4%".
    var projectedDeltaLabel: String {
        let pct = Int(projectedReadinessDelta * 100)
        return pct > 0 ? "+\(pct)%" : "\(pct)%"
    }

    // MARK: - Dependencies

    private let service: TopicCompetenceService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(service: TopicCompetenceService) {
        self.service = service

        // Issue 5 fix: Task { @MainActor } to satisfy strict concurrency.
        service.$competences
            .receive(on: RunLoop.main)
            .sink { [weak self] updated in
                Task { @MainActor [weak self] in
                    self?.competences = updated
                    self?.recalculate(from: updated)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Private

    private func recalculate(from competences: [TopicArea: TopicCompetence]) {
        let all     = TopicArea.allCases.map { competences[$0] ?? TopicCompetence(topic: $0) }
        let started = all.filter { $0.totalAnswers > 0 }

        overallReadinessScore = started.isEmpty
            ? 0.0
            : started.map(\.weightedAccuracy).reduce(0, +) / Double(started.count)

        // Projected delta: estimate readiness gain from one more complete session.
        // Approximation — one session touches (minimumQuestions) topics.
        // Each topic's EMA moves by (1 - decay) * (outcome - current).
        // Conservative estimate: weak topics improve by 0.1 on average.
        let sessionTopicCount = Double(service.config.minimumQuestions)
        let topicCount        = Double(TopicArea.allCases.count)
        projectedReadinessDelta = (sessionTopicCount / topicCount) * 0.1
    }
}