import Foundation
import Combine

final class RegionalOnboardingViewModel: ObservableObject {
    @Published var selectedRegion: Region
    @Published var showDisclaimer = false
    @Published var isLoading = false

    private let regionalConfigService: RegionalConfigurationServiceProtocol
    private let dataDeletionService: DataDeletionService
    private var cancellables = Set<AnyCancellable>()

    init(regionalConfigService: RegionalConfigurationServiceProtocol,
         dataDeletionService: DataDeletionService) {
        self.regionalConfigService = regionalConfigService
        self.dataDeletionService = dataDeletionService

        // Initialize with current region
        self.selectedRegion = regionalConfigService.currentRegion
    }

    func saveRegion() async throws {
        isLoading = true
        defer { isLoading = false }

        if selectedRegion != regionalConfigService.currentRegion {
            try regionalConfigService.updateRegion(selectedRegion)
        }
    }

    func deleteExistingData() async throws {
        isLoading = true
        defer { isLoading = false }

        _ = try dataDeletionService.deleteAllUserData()
    }
}