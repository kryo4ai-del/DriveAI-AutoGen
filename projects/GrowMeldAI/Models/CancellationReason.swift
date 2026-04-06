enum SubscriptionStatus {
    case cancelled(expiresUntil: Date, reason: CancellationReason?, cancelledDate: Date)

    enum CancellationReason: String, Codable {
        case userInitiated
        case paymentFailed
        case customerServiceRequest
        case unknown
    }
}