import Foundation
import Combine

/// ViewModel for Apple Search Ads campaign management
final class ASAViewModel: ObservableObject {
    @Published var copyVariants: [ASACopyVariant] = []
    @Published var targetingParams: ASATargetingParams
    @Published var complianceStatus: ASAComplianceStatus = .unknown
    @Published var isCampaignReady: Bool = false

    private let complianceChecker: ASAComplianceChecker
    private var cancellables = Set<AnyCancellable>()

    init(complianceChecker: ASAComplianceChecker) {
        self.complianceChecker = complianceChecker
        self.targetingParams = .makeGermanTargeting()
        setupBindings()
    }

    private func setupBindings() {
        $copyVariants
            .combineLatest($targetingParams)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateCompliance()
            }
            .store(in: &cancellables)
    }

    private func validateCompliance() {
        do {
            try complianceChecker.validateCampaign(
                copyVariants: copyVariants,
                targeting: targetingParams
            )
            complianceStatus = .compliant
            isCampaignReady = true
        } catch {
            complianceStatus = .nonCompliant(error.localizedDescription)
            isCampaignReady = false
        }
    }

    func resetToDefaultCopy() {
        copyVariants = ASACopyVariant.makeEmotionalCopy()
    }

    func addCopyVariant(_ variant: ASACopyVariant) {
        copyVariants.append(variant)
    }
}

enum ASAComplianceStatus {
    case unknown
    case compliant
    case nonCompliant(String)
}