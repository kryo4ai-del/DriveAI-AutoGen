// Modules/Subscription/Services/ProrateCalculator.swift

struct ProrateCalculation {
    let monthlyPrice: Decimal = 4.99
    let yearlyPrice: Decimal = 49.99
    let creditAmount: Decimal
    let finalPrice: Decimal
    
    var displayCredit: String {
        NumberFormatter.currencyFormatter(for: "EUR").string(from: creditAmount as NSNumber) ?? "€0.00"
    }
    
    var displayFinal: String {
        NumberFormatter.currencyFormatter(for: "EUR").string(from: finalPrice as NSNumber) ?? "€0.00"
    }
}

// Helper for rounding to currency precision
extension Decimal {
    func rounded(toPlaces places: Int) -> Decimal {
        var value = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, places, .plain)
        return rounded
    }
}

// Usage in SubscriptionManager:
func upgradeToYearly(billingCycleEndDate: Date) async throws {
    guard case .active(let monthlyPlan) = state else {
        throw SubscriptionError.invalidStateForUpgrade
    }
    
    let proration = prorateCalculator.calculateMonthlyToYearlyCredit(
        billingCycleEndDate: billingCycleEndDate  // ← Pass actual cycle end, not trial days
    )
    
    let yearlyPlan = YearlySubscriptionPlan(
        price: proration.finalPrice,
        currency: "EUR",
        autoRenews: true,
        createdAt: Date()
    )
    
    try await dataStore.save(subscriptionState: .yearly(yearlyPlan))
    self.state = .yearly(yearlyPlan)
    
    AnalyticsService.shared.log(
        event: "upgraded_monthly_to_yearly",
        parameters: [
            "original_price": Double(monthlyPlan.price),
            "credit": Double(proration.creditAmount),
            "final_price": Double(proration.finalPrice)
        ]
    )
}