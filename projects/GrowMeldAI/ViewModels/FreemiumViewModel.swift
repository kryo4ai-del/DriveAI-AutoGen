class FreemiumViewModel: ObservableObject {
    let quotaManager: QuotaManager = .shared  // ← Strong ref OK (singleton)
    
    // But if you have computed properties or delegates:
    var onQuotaExceeded: () -> Void = {
        self.showPaywall = true  // ← Potential retain cycle
    }
}