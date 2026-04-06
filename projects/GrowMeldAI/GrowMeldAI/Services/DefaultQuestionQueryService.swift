import Foundation
import Combine

final class DefaultQuestionQueryService: QuestionQueryService, ObservableObject {
    private let dataService: LocalDataService
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    init(dataService: LocalDataService = LocalDataService.shared) {
        self.dataService = dataService
        loadIndexes()
    }

    // MARK: - QuestionQueryService

    func filter(by filter: QueryFilter) -> [Question] {
        guard !filter.isEmpty else { return [] }
        return dataService.questions.filter { question in
            filter.locations.contains(question.location) &&
            filter.sizeClasses.contains(question.sizeClass) &&
            (filter.minDifficulty == nil || question.difficulty >= filter.minDifficulty!) &&
            (filter.maxDifficulty == nil || question.difficulty <= filter.maxDifficulty!)
        }
    }

    func examSimulation(
        count: Int,
        minDifficulty: Int,
        locationBalancing: Bool
    ) async throws -> [Question] {
        let allQuestions = dataService.questions
        let filtered = allQuestions.filter { $0.difficulty >= minDifficulty }

        guard !filtered.isEmpty else { return [] }

        var selectedQuestions: [Question]

        if locationBalancing {
            let locations = Location.allCases
            let questionsPerLocation = max(1, count / locations.count)
            selectedQuestions = locations.flatMap { location in
                filtered.filter { $0.location == location }.shuffled().prefix(questionsPerLocation)
            }
        } else {
            selectedQuestions = filtered.shuffled().prefix(count)
        }

        return Array(selectedQuestions.prefix(count))
    }

    func availableLocations() -> [Location] {
        Location.allCases
    }

    func availableSizeClasses() -> [SizeClass] {
        SizeClass.allCases
    }

    func statistics(filter: QueryFilter) -> QueryStatistics {
        let allQuestions = dataService.questions
        let filteredQuestions = filter(by: filter)

        let difficultyDistribution = Dictionary(
            grouping: allQuestions,
            by: { $0.difficulty }
        ).mapValues { $0.count }

        let locationDistribution = Dictionary(
            grouping: allQuestions,
            by: { $0.location }
        ).mapValues { $0.count }

        let sizeClassDistribution = Dictionary(
            grouping: allQuestions,
            by: { $0.sizeClass }
        ).mapValues { $0.count }

        return QueryStatistics(
            totalQuestions: allQuestions.count,
            filteredCount: filteredQuestions.count,
            difficultyDistribution: difficultyDistribution,
            locationDistribution: locationDistribution,
            sizeClassDistribution: sizeClassDistribution
        )
    }

    func filterExplanation(for filter: QueryFilter) -> String {
        guard !filter.isEmpty else {
            return "Alle Fragen werden angezeigt"
        }

        var components: [String] = []

        if !filter.locations.isEmpty {
            let locationNames = filter.locations.map { $0.displayName }.joined(separator: ", ")
            components.append("Ort: \(locationNames)")
        }

        if !filter.sizeClasses.isEmpty {
            let sizeNames = filter.sizeClasses.map { $0.displayName }.joined(separator: ", ")
            components.append("Schwierigkeit: \(sizeNames)")
        }

        if let minDiff = filter.minDifficulty, let maxDiff = filter.maxDifficulty {
            components.append("Schwierigkeit: \(minDiff)-\(maxDiff)")
        } else if let minDiff = filter.minDifficulty {
            components.append("Schwierigkeit: ab \(minDiff)")
        } else if let maxDiff = filter.maxDifficulty {
            components.append("Schwierigkeit: bis \(maxDiff)")
        }

        return components.isEmpty ? "Keine Filter aktiv" : "Gefiltert nach: \(components.joined(separator: "; "))"
    }

    // MARK: - Index Management

    private func loadIndexes() {
        isLoading = true
        dataService.loadQuestionsWithMeta()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func warmIndexes() async {
        await dataService.cacheLocationIndex()
    }
}