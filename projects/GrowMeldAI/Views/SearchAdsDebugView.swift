// Debug/SearchAdsDebugView.swift

#if DEBUG
struct SearchAdsDebugView: View {
    @State private var attributionToken: String = "Loading..."
    @State private var isLoading = false
    
    private let searchAdsService: SearchAdsAttributionProvider
    
    init(searchAdsService: SearchAdsAttributionProvider) {
        self.searchAdsService = searchAdsService
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Ads Debug")
                .font(.headline)
            
            Button(action: fetchToken) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Fetch Attribution Token")
                }
            }
            .disabled(isLoading)
            
            Text("Token: \(attributionToken)")
                .font(.caption)
                .lineLimit(3)
                .textSelection(.enabled)
            
            Divider()
            
            Text("Config Status")
                .font(.subheadline)
            Text("Active: \(RemoteConfigManager.shared.searchAdsConfig.isActive)")
            Text("Legally Approved: \(RemoteConfigManager.shared.searchAdsConfig.legallyApprovedDate != nil)")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func fetchToken() {
        isLoading = true
        Task {
            do {
                let token = try await searchAdsService.fetchAttributionToken()
                await MainActor.run {
                    attributionToken = token
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    attributionToken = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}
#endif