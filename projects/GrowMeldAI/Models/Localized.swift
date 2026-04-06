enum Localized {
    enum IAP {
        enum Paywall {
            static let title = NSLocalizedString(
                "iap.paywall.title",
                comment: "Paywall screen: top navigation title"
            )
            static let headline = NSLocalizedString(
                "iap.paywall.headline",
                comment: "Paywall: main headline about exam confidence"
            )
        }
    }
}

// Usage
Text(Localized.IAP.Paywall.title)