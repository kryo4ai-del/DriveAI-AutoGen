import Foundation

enum PurchaseState: Equatable {
    case idle
    case loading(productId: String)
    case purchaseInitiated(productId: String)
    case success(feature: UnlockableFeature, transactionId: String)
    case error(PurchaseError)
    case restoring
    case completed
    
    var isLoading: Bool {
        switch self {
        case .loading, .restoring, .purchaseInitiated:
            return true
        default:
            return false
        }
    }
    
    var currentProductId: String? {
        switch self {
        case .loading(let id), .purchaseInitiated(let id):
            return id
        default:
            return nil
        }
    }
}
