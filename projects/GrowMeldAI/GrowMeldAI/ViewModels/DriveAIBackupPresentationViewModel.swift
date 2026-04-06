// File: DriveAIBackupPresentationViewModel.swift
import Foundation
import Combine

/// ViewModel for DriveAI backup presentation
final class DriveAIBackupPresentationViewModel: ObservableObject {
    @Published var isFeatureEnabled: Bool = true
    @Published var complianceStatus: ComplianceStatus = .init(
        gdprCompliant: false,
        appStoreCompliant: false,
        consumerProtectionCompliant: false
    )

    private let generator = DriveAIBackupPresentationGenerator()
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var userPresentation: UserPresentation?
    @Published private(set) var internalPresentation: InternalPresentation?

    init() {
        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest($isFeatureEnabled, $complianceStatus)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .map { [generator] featureEnabled, status in
                generator.generateInternalPresentation(
                    featureEnabled: featureEnabled,
                    complianceStatus: status
                )
            }
            .assign(to: \.internalPresentation, on: self)
            .store(in: &cancellables)

        $isFeatureEnabled
            .combineLatest($complianceStatus)
            .map { [generator] featureEnabled, _ in
                generator.generateUserPresentation()
            }
            .assign(to: \.userPresentation, on: self)
            .store(in: &cancellables)
    }

    func updateComplianceStatus(gdpr: Bool, appStore: Bool, consumerProtection: Bool) {
        complianceStatus = ComplianceStatus(
            gdprCompliant: gdpr,
            appStoreCompliant: appStore,
            consumerProtectionCompliant: consumerProtection
        )
    }
}