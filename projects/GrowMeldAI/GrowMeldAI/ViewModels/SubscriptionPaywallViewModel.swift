import Foundation
import Combine

@MainActor
final class SubscriptionPaywallViewModel: ObservableObject {
    @Published var plans: [SubscriptionPlan] = []
    @Published var selectedPlanId: String?
    @Published var isPurchasing = false
    @Published var purchaseError: PurchaseError?
    @Published var showPurchaseError = false
    
    private let subscriptionService: SubscriptionService
    private var purchaseTimeout: Task<Void, Never>?
    
    init(subscriptionService: SubscriptionService) {
        self.subscriptionService = subscriptionService
        self.plans = subscriptionService.availablePlans
        self.selectedPlanId = plans.first?.id
    }
    
    func selectPlan(_ planId: String) {
        selectedPlanId = planId
    }
    
    func purchaseSelectedPlan() async {
        guard let plan = plans.first(where: { $0.id == selectedPlanId }) else {
            purchaseError = .invalidPlan
            showPurchaseError = true
            return
        }
        
        await purchase(plan)
    }
    
    private func purchase(_ plan: SubscriptionPlan) async {
        isPurchasing = true
        showPurchaseError = false
        purchaseError = nil
        
        defer { isPurchasing = false }
        
        // 30-second timeout
        purchaseTimeout = Task {
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            if self.isPurchasing {
                self.isPurchasing = false
                self.purchaseError = .unknown("Kauf-Timeout")
                self.showPurchaseError = true
            }
        }
        
        let result = await subscriptionService.purchase(plan)
        
        purchaseTimeout?.cancel()
        purchaseTimeout = nil
        
        switch result {
        case .success:
            // Success announcement handled by view layer
            break
        case .failure(let error):
            purchaseError = error
            showPurchaseError = true
        }
    }
}