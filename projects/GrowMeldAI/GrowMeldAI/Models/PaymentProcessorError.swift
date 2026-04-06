enum PaymentProcessorError: LocalizedError {
    case networkUnavailable
    case invalidPaymentMethod(reason: String)
    case cardDeclined(code: String)
    case insufficientFunds
    case threeDSecureRequired  // Explicit 3D Secure handling
    case fraudDetected
    case processorMaintenance
    case timeout
    case unknown(statusCode: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .threeDSecureRequired:
            return NSLocalizedString("3D Secure verification required", comment: "Payment error")
        // ... others
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .processorMaintenance:
            return true
        default:
            return false
        }
    }
}