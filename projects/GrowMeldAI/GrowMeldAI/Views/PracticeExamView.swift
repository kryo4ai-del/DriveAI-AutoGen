// ✅ GOOD: Centralized entitlement state
@MainActor

// Usage in any view:
struct PracticeExamView: View {
    @StateObject var entitlements: EntitlementService
    
    var body: some View {
        if entitlements.hasFeatureAccess("unlimited_exams") {
            PracticeExamContent()
        } else {
            PaywallView()
        }
    }
}

// ❌ AVOID: Scattered permission checks
// Each view asking StoreKit "do I have access?"
// → Multiple sources of truth
// → Cache invalidation bugs