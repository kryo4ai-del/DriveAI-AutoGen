import Foundation
import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var showRegionConfirmation = false
    @Published var selectedRegionToSwitch: Region?

    let regionManager: RegionManager

    init(regionManager: RegionManager = RegionManager()) {
        self.regionManager = regionManager
    }

    func requestRegionSwitch(to newRegion: Region) {
        selectedRegionToSwitch = newRegion
        showRegionConfirmation = true
    }

    func confirmRegionSwitch() {
        guard let newRegion = selectedRegionToSwitch else { return }
        regionManager.switchRegion(newRegion)
        showRegionConfirmation = false
    }
}