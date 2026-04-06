import Foundation
import SwiftUI
import Combine

// MARK: - Supporting Types

enum ABTestingError: Error {
    case serializationFailed(key: String, reason: String)
    case experimentNotFound(id: String)
    case variantUnavailable
    case registrationFailed(String)
}

struct ABExperiment: Identifiable, Codable {
    let id: String
    let name: String
    let variants: [String]
}

struct ABVariant: Codable {
    let experimentId: String
    let variantKey: String
}

// MARK: - ABTestingService

protocol ABTestingServiceProtocol {
    func registerExperiment(_ experiment: ABExperiment) async throws
    func getVariant(for userId: String, experimentId: String) async -> ABVariant?
}

final class ABTestingService: ABTestingServiceProtocol {
    private var registeredExperiments: [String: ABExperiment] = [:]
    private var assignments: [String: String] = [:]

    func registerExperiment(_ experiment: ABExperiment) async throws {
        registeredExperiments[experiment.id] = experiment
    }

    func getVariant(for userId: String, experimentId: String) async -> ABVariant? {
        guard let experiment = registeredExperiments[experimentId],
              !experiment.variants.isEmpty else {
            return nil
        }

        let assignmentKey = "\(userId)_\(experimentId)"
        if let existing = assignments[assignmentKey] {
            return ABVariant(experimentId: experimentId, variantKey: existing)
        }

        // Deterministic assignment based on userId + experimentId hash
        let hash = abs((userId + experimentId).hashValue)
        let variantKey = experiment.variants[hash % experiment.variants.count]
        assignments[assignmentKey] = variantKey
        return ABVariant(experimentId: experimentId, variantKey: variantKey)
    }
}

// MARK: - ABTestingViewModel

@MainActor
class ABTestingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var experiments: [ABExperiment] = []
    @Published var currentVariants: [String: ABVariant] = [:]
    @Published var isLoading: Bool = false
    @Published var error: ABTestingError?

    // MARK: - Dependencies

    private let service: ABTestingServiceProtocol
    private let userId: String

    // MARK: - Init

    init(
        service: ABTestingServiceProtocol = ABTestingService(),
        userId: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    ) {
        self.service = service
        self.userId = userId
    }

    // MARK: - Public Methods

    func loadExperiment(_ experiment: ABExperiment) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.registerExperiment(experiment)

            let variant = await service.getVariant(
                for: userId,
                experimentId: experiment.id
            )

            self.currentVariants[experiment.id] = variant
            if !self.experiments.contains(where: { $0.id == experiment.id }) {
                self.experiments.append(experiment)
            }

        } catch {
            self.error = error as? ABTestingError ?? .serializationFailed(key: "", reason: "Unknown")
        }
    }

    func loadExperiments(_ experiments: [ABExperiment]) async {
        await withTaskGroup(of: Void.self) { group in
            for experiment in experiments {
                group.addTask { [weak self] in
                    await self?.loadExperiment(experiment)
                }
            }
        }
    }

    func variant(for experimentId: String) -> ABVariant? {
        currentVariants[experimentId]
    }

    func variantKey(for experimentId: String) -> String? {
        currentVariants[experimentId]?.variantKey
    }

    func resetExperiments() {
        experiments = []
        currentVariants = [:]
        error = nil
    }
}