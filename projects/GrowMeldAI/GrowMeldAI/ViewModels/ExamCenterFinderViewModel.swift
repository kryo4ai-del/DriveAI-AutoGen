@MainActor
final class ExamCenterFinderViewModel: ObservableObject {
    @Published var nearbyExamCenters: [ExamCenter] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var selectedSortOption: SortOption = .distance
    
    @Dependency var locationDataService: LocationDataService
    @Dependency var examCenterLocator: ExamCenterLocator
    
    func loadNearbyExamCenters() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let location = try await locationDataService.getCurrentLocation()
            nearbyExamCenters = examCenterLocator.nearbyExamCenters(
                from: location,
                within: 25.0
            ).sorted(by: selectedSortOption)
        } catch {
            // Handle location denied, unavailable, etc.
            // Fallback: Show search-by-city UI
        }
    }
    
    func deleteStoredLocationData() async {
        await locationDataService.deleteOldLocationData(olderThan: .now)
    }
}