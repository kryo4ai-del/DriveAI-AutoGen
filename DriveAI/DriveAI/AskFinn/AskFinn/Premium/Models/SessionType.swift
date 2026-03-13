// Models/SessionType.swift

/// Adaptive strategy for building a training question queue.
enum SessionType: Equatable {
    case adaptive
    case weaknessFocus
    case spacingReview
    case coverageGaps
    case custom(topics: [TopicArea])
}
