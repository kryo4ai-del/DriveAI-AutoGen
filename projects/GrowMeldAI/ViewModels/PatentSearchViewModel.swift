// PatentSearchViewModel.swift
import Foundation
import Combine

@MainActor
final class PatentSearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var patents: [Patent] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedPatent: Patent?
    @Published var verificationResults: [UUID: VerificationResult] = [:]

    private let repository: PatentRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: PatentRepository = LocalPatentRepository()) {
        self.repository = repository
        setupBindings()
    }

    private func setupBindings() {
        $searchQuery
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task { await self?.performSearch(query: query) }
            }
            .store(in: &cancellables)
    }

    func performSearch(query: String) async {
        guard !query.isEmpty else {
            await loadAllPatents()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            patents = try await repository.searchPatents(query: query)
            await verifyPatents()
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func loadAllPatents() async {
        isLoading = true
        errorMessage = nil

        do {
            patents = try await repository.fetchPatents()
            await verifyPatents()
        } catch {
            errorMessage = "Failed to load patents: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func verifyPatents() async {
        for patent in patents {
            if verificationResults[patent.id] == nil {
                let result = await PatentVerificationService.shared.verifyPatent(patent)
                verificationResults[patent.id] = result
            }
        }
    }

    func verifyPatent(_ patent: Patent) async {
        let result = await PatentVerificationService.shared.verifyPatent(patent)
        verificationResults[patent.id] = result
    }

    func clearSearch() {
        searchQuery = ""
        patents = []
    }
}