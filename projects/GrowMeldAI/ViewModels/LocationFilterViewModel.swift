import Foundation
import Combine

@MainActor
class LocationFilterViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var favoriteRegions: [PLZRegion] = []
    @Published var selectedRegion: PLZRegion?
    init() {}
}
