@MainActor
final class SubscriptionManager {
    func startFreeTrial(_ productId: String) async throws
    func cancelSubscription(_ productId: String) async throws
    func handleSubscriptionRenewal(_ transaction: Transaction)
    func checkIfUserCanResubscribe() -> Bool
    func logSubscriptionEvent(_ event: SubscriptionEvent)
}

enum SubscriptionEvent: String {
    case started, renewed, expired, cancelled, failedRenewal
}