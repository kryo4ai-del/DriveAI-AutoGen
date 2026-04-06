// Services/Errors/PurchaseError.swift - Add accessible description method
extension PurchaseError {
    /// Full accessible description combining error + recovery suggestion
    var accessibleDescription: String {
        var message = errorDescription ?? NSLocalizedString("Fehler", comment: "Error")
        if let suggestion = recoverySuggestion {
            message += ". \(suggestion)"
        }
        return message
    }
}

// ViewModels/Premium/PremiumFeaturesViewModel.swift
func handlePurchaseError(_ error: PurchaseError) {
    self.error = error
    
    // Announce to accessibility clients
    UIAccessibility.post(
        notification: .announcement,
        argument: error.accessibleDescription
    )
}