@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var showRegionConfirmation = false
    @Published var selectedRegionToSwitch: Region?
    
    let regionManager: RegionManager
    
    func requestRegionSwitch(to newRegion: Region) {
        selectedRegionToSwitch = newRegion
        showRegionConfirmation = true
    }
    
    func confirmRegionSwitch() {
        guard let newRegion = selectedRegionToSwitch else { return }
        regionManager.switchRegion(newRegion)
        // Progress is preserved in UserDefaults keyed by region
        showRegionConfirmation = false
    }
}