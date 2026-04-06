// File: ViewModels/TrafficSignViewModel.swift
import Foundation
import Combine

@MainActor
class TrafficSignViewModel: ObservableObject {
    @Published private(set) var trafficSigns: [TrafficSign] = []
    @Published private(set) var filteredSigns: [TrafficSign] = []
    @Published private(set) var categories: [TrafficSignCategory] = TrafficSignCategory.allCases
    @Published private(set) var difficultyLevels: [DifficultyLevel] = DifficultyLevel.allCases
    @Published var selectedCategory: TrafficSignCategory?
    @Published var selectedDifficulty: DifficultyLevel?
    @Published var searchText: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        loadSampleData()
    }

    private func setupBindings() {
        Publishers.CombineLatest3($selectedCategory, $selectedDifficulty, $searchText)
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .sink { [weak self] category, difficulty, searchText in
                self?.applyFilters(category: category, difficulty: difficulty, searchText: searchText)
            }
            .store(in: &cancellables)
    }

    private func loadSampleData() {
        // In a real app, this would load from a proper data source
        trafficSigns = [
            TrafficSign(
                signNumber: "274.1",
                name: "Speed Limit 30",
                description: "Indicates a speed limit of 30 km/h in certain areas like near schools.",
                category: .speedLimit,
                difficulty: .beginner,
                imageName: "speed_limit_30",
                isRegulatory: true
            ),
            TrafficSign(
                signNumber: "205",
                name: "Give Way",
                description: "Drivers must give way to traffic on the main road.",
                category: .priority,
                difficulty: .beginner,
                imageName: "give_way",
                isRegulatory: true
            ),
            TrafficSign(
                signNumber: "131",
                name: "Wild Animal Crossing",
                description: "Warning for potential wild animal crossings.",
                category: .warning,
                difficulty: .intermediate,
                imageName: "wild_animals",
                isWarning: true
            ),
            TrafficSign(
                signNumber: "250",
                name: "No Entry",
                description: "Entry to this road is prohibited in the direction shown.",
                category: .regulatory,
                difficulty: .beginner,
                imageName: "no_entry",
                isRegulatory: true
            )
        ]
        filteredSigns = trafficSigns
    }

    private func applyFilters(category: TrafficSignCategory?,
                             difficulty: DifficultyLevel?,
                             searchText: String) {
        var filtered = trafficSigns

        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }

        if let difficulty = difficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.signNumber.localizedCaseInsensitiveContains(searchText)
            }
        }

        filteredSigns = filtered
    }

    func resetFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        searchText = ""
    }
}