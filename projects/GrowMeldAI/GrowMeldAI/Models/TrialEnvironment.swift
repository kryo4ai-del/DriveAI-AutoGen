import Foundation

/// Dependency injection container for trial features
struct TrialEnvironment {
    let coordinator: TrialCoordinator
    let purchaseManager: PurchaseFlowViewModel
    
    static func make() -> TrialEnvironment {
        let persistence = TrialPersistenceService()
        let validator = TrialCacheValidator()
        let coordinator = TrialCoordinator(
            persistence: persistence,
            validator: validator
        )
        
        let purchaseManager = PurchaseFlowViewModel(coordinator: coordinator)
        
        return TrialEnvironment(
            coordinator: coordinator,
            purchaseManager: purchaseManager
        )
    }
}