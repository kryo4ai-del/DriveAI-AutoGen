// ToxicityWarningViewModel.swift
import Foundation
import Combine

@MainActor
final class ToxicityWarningViewModel: ObservableObject {
    @Published private(set) var warnings: [ToxicityWarning] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let dataService: ToxicityWarningDataService
    private var cancellables = Set<AnyCancellable>()

    init(dataService: ToxicityWarningDataService = LocalToxicityWarningService()) {
        self.dataService = dataService
    }

    func loadWarnings() async {
        isLoading = true
        error = nil

        do {
            warnings = try await dataService.fetchAllWarnings()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }

    func warnings(for questionId: String) -> [ToxicityWarning] {
        warnings.filter { warning in
            warning.questionLinks.contains { $0.questionIds.contains(questionId) }
        }
    }

    func filterWarnings(by group: AffectedGroup) -> [ToxicityWarning] {
        warnings.filter { $0.affectedGroups.contains(group) }
    }
}

/// Protocol for the data service to allow mocking in tests
protocol ToxicityWarningDataService {
    func fetchAllWarnings() async throws -> [ToxicityWarning]
    func fetchWarning(withId id: String) async throws -> ToxicityWarning?
}