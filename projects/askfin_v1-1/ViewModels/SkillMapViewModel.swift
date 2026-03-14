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

    /// Formatted projected delta, e.g. "+4%". Nil when zero.
    var projectedDeltaLabel: String? {
        let pct = Int(projectedReadinessDelta * 100)
        guard pct != 0 else { return nil }
        return pct > 0 ? "+\(pct)%" : "\(pct)%"
    }

    // MARK: - Dependencies

    private let service: TopicCompetenceService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(service: TopicCompetenceService) {
        self.service = service

        // Subscribe to competenceMap [String: TopicCompetence] and convert to
        // [TopicArea: TopicCompetence] for type-safe domain section building.
        service.$competenceMap
            .receive(on: RunLoop.main)
            .sink { [weak self] stringKeyed in
                Task { @MainActor [weak self] in
                    let mapped = Dictionary(uniqueKeysWithValues:
                        stringKeyed.compactMap { key, value in
                            TopicArea(rawValue: key).map { ($0, value) }
                        }
                    )
                    self?.competences = mapped
                    self?.recalculate(from: mapped)
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
        // Conservative estimate: ~10 questions per session, weak topics improve 0.1.
        let sessionTopicCount = 10.0
        let topicCount        = Double(TopicArea.allCases.count)
        projectedReadinessDelta = (sessionTopicCount / topicCount) * 0.1
    }
}
