@Observable
@MainActor
final class LocationPickerViewModel {
    enum State: Sendable {
        case idle
        case searching(query: String)
        case loaded(region: PostalCodeRegion)
        case error(LocationError)
    }
    
    nonisolated private let repository: LocationRepository
    
    var state: State = .idle
    var searchText: String = ""
    var recentSearches: [PostalCodeRegion] = []
    
    init(repository: LocationRepository) {
        self.repository = repository
    }
    
    // Debounced search with cancellation support
    private var searchTask: Task<Void, Never>?
    
    func search(_ plz: String) async {
        // Cancel previous search if still running
        searchTask?.cancel()
        
        state = .searching(query: plz)
        
        // Debounce 300ms to prevent excessive queries
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            guard !Task.isCancelled else { return }
            
            do {
                let region = try await repository.lookupPostalCode(plz)
                
                guard !Task.isCancelled else { return }
                
                state = .loaded(region: region)
                addToRecent(region)
            } catch {
                guard !Task.isCancelled else { return }
                
                state = .error(error as? LocationError ?? .unknown)
            }
        }
    }
    
    private func addToRecent(_ region: PostalCodeRegion) {
        if !recentSearches.contains(where: { $0.id == region.id }) {
            recentSearches.insert(region, at: 0)
            if recentSearches.count > 5 {
                recentSearches.removeLast()
            }
        }
    }
}