@MainActor
final class RegionManager: ObservableObject {
    @Published private(set) var currentRegion: Region
    @Published private(set) var regionMetadata: RegionMetadata
    @Published private(set) var regionConfig: RegionConfig
    
    private let defaults: UserDefaults
    
    init(
        initialRegion: Region = .dach,
        userDefaults: UserDefaults = .standard
    ) {
        self.defaults = userDefaults
        
        let saved = userDefaults.string(forKey: UserDefaultsKey.selectedRegion) ?? "dach"
        let region = Region(rawValue: saved) ?? initialRegion
        
        // Initialize all properties before @Published activation
        self.currentRegion = region
        self.regionMetadata = RegionMetadata.metadata(for: region)
        self.regionConfig = RegionConfig.config(for: region)
    }
    
    func switchRegion(_ region: Region) async {
        guard region != currentRegion else { return }
        
        await MainActor.run {
            self.currentRegion = region
            self.regionMetadata = RegionMetadata.metadata(for: region)
            self.regionConfig = RegionConfig.config(for: region)
            self.persistRegion()
        }
    }
    
    private func persistRegion() {
        defaults.set(currentRegion.rawValue, forKey: UserDefaultsKey.selectedRegion)
    }
}