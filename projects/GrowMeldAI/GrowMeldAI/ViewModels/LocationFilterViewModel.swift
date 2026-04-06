@MainActor
final class LocationFilterViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var favoriteRegions: [PLZRegion] = []
    @Published var recentSearches: [String] = []
    
    var filteredRegions: [PLZRegion] {
        // Search + filter logic
    }
    
    private let plzService: PLZMappingService
    private let userDefaults = UserDefaults.standard
    
    func saveFavorite(_ region: PLZRegion) {
        // Persist to UserDefaults
    }
    
    func loadFavorites() {
        // Hydrate from UserDefaults
    }
}