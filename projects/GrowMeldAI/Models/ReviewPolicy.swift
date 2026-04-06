enum ReviewPolicy: Sendable {
    static let reviewIntervalDays: TimeInterval = 7.0
}

var needsReview: Bool {
    guard let lastReview = lastReviewDate else { return true }
    let reviewInterval = ReviewPolicy.reviewIntervalDays * 24 * 60 * 60
    return Date().timeIntervalSince(lastReview) > reviewInterval
}