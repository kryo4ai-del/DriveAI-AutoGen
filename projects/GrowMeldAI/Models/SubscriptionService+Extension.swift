extension SubscriptionService {
    func calculateProrationCredit(
        currentPlan: SubscriptionPlan,
        renewsAt: Date,
        upgradeToPlan: SubscriptionPlan
    ) async -> Decimal {
        let daysRemaining = Calendar.current.dateComponents([.day], from: .now, to: renewsAt).day ?? 0
        let dailyRate = currentPlan.price.amount / 30  // Simplified
        let creditAmount = dailyRate * Decimal(daysRemaining)
        return creditAmount
    }
    
    func upgrade(fromPlan: SubscriptionPlan, toPlan: SubscriptionPlan) async throws {
        let credit = await calculateProrationCredit(
            currentPlan: fromPlan,
            renewsAt: subscription.state.expiryDate ?? .now,
            upgradeToPlan: toPlan
        )
        
        // Apply credit to new plan cost
        let effectivePrice = max(0, toPlan.price.amount - credit)
        // Show user: "Upgrade to annual for only €50 (€39.99 credit applied)"
        
        try subscription.activate(plan: toPlan)
        try await repository.save(subscription)
    }
}