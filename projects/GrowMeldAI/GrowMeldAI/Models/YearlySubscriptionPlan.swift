struct YearlySubscriptionPlan: SubscriptionPlan {
    let id: UUID
    let price: Decimal
    let currency: String
    let autoRenews: Bool
    let createdAt: Date
    
    // Year-specific properties
    let renewalDate: Date
}