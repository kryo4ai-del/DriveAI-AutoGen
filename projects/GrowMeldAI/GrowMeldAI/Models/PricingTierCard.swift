struct PricingTierCard: View {
    let product: IAPProduct
    
    var formattedPrice: String {
        let priceFormatter = NumberFormatter()
        priceFormatter.locale = Locale.current
        priceFormatter.numberStyle = .currency
        
        // Use Apple's currency (from product.priceCurrency)
        if let price = product.price {
            priceFormatter.currencyCode = product.priceCurrency
            if let formatted = priceFormatter.string(from: NSNumber(value: price.doubleValue)) {
                return formatted
            }
        }
        
        return product.displayPrice
    }
    
    var body: some View {
        // ...
        Text(formattedPrice)
            .font(.title3)
            .fontWeight(.bold)
        // ...
    }
}