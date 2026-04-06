import SwiftUI
import Combine

@MainActor
class AgeGatingViewModel: ObservableObject {
    @Published var confirmedAge = false
    @Published var parentEmail = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    var canProceed: Bool {
        confirmedAge
    }

    private let complianceService: ComplianceService

    init(complianceService: ComplianceService) {
        self.complianceService = complianceService
    }

    func proceedToApp(regime: ComplianceRegime) async {
        isLoading = true
        errorMessage = nil

        do {
            try await complianceService.verifyAge(
                regime.minimumAge,
                method: .selfReport
            )
            // Proceed to main app
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}