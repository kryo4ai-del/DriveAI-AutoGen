enum CheckoutStep {
    case selectPlan  // Only: product name, price, "Choose this"
    case confirmTrial  // Only: "14-day free trial. You'll be charged on day 15."
    case reviewPayment  // Only: total price, VAT transparency, terms link
    case success  // Celebration frame
}

@Published var checkoutStep: CheckoutStep = .selectPlan