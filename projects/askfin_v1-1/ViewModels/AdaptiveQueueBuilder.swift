import Foundation

/// Builds an ordered, deduplicated topic queue for an adaptive training session.
///
/// Pure value type: takes arrays in, returns an array out.
/// No ObservableObject, no Combine, fully testable with plain XCTest.
struct AdaptiveQueueBuilder {

    let config: TrainingConfig

    /// Priority order: spacing-due → weakest → coverage gaps → random fill to minimum.
    ///
    /// First-seen ordering is preserved across all three source arrays so
    /// a topic that appears in both `due` and `weakest` only occupies one slot,
    /// positioned where it first appeared (i.e. in the higher-priority group).
    func build(
        due: [TopicArea],
        weakest: [TopicArea],
        leastCovered: [TopicArea]
    ) -> [TopicArea] {
        var seen = Set<TopicArea>()
        var queue: [TopicArea] = []

        for topic in due + weakest + leastCovered {
            if seen.insert(topic).inserted {
                queue.append(topic)
            }
        }

        // Pad to minimumQuestions using topics not yet in the queue.
        let remaining = TopicArea.allCases
            .filter { !seen.contains($0) }
            .shuffled()
        let deficit = max(0, config.minimumQuestions - queue.count)
        queue += remaining.prefix(deficit)

        return Array(queue.prefix(config.maximumQuestions))
    }
}
