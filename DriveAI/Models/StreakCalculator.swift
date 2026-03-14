// Services/StreakCalculator.swift
final class StreakCalculator {
    func calculateStreak(from results: [SimulationResult]) -> Int {
        guard !results.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let sorted = results.sorted { $0.completedAt > $1.completedAt }
        
        var streak = 0
        var expectedDate = today
        
        for result in sorted {
            let resultDate = calendar.startOfDay(for: result.completedAt)
            
            if resultDate == expectedDate {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate) ?? today
            } else {
                break
            }
        }
        
        return streak
    }
}

// Services/ReadinessCalculator.swift
final class ReadinessCalculator {
    private let streakCalculator: StreakCalculator
    
    init(streakCalculator: StreakCalculator = .init()) {
        self.streakCalculator = streakCalculator
    }
    
    func calculate(from results: [SimulationResult]) -> ExamReadiness {
        let passedCount = results.filter { $0.passed }.count
        let totalCount = results.count
        let avgScore = results.isEmpty ? 0 : results.map { $0.score }.reduce(0, +) / Double(results.count)
        let streak = streakCalculator.calculateStreak(from: results)
        let weaknesses = identifyWeaknesses(from: results)
        
        return ExamReadiness(
            passedSimulations: passedCount,
            totalSimulations: totalCount,
            averageScore: avgScore,
            streakDays: streak,
            categoryWeaknesses: weaknesses,
            lastSimulationDate: results.first?.completedAt
        )
    }
    
    private func identifyWeaknesses(from results: [SimulationResult]) -> [String] {
        guard !results.isEmpty else { return [] }
        
        var categoryTotals: [String: (correct: Int, total: Int)] = [:]
        
        for result in results {
            for score in result.categoryScores {
                let current = categoryTotals[score.categoryName] ?? (0, 0)
                categoryTotals[score.categoryName] = (
                    current.correct + score.correct,
                    current.total + score.total
                )
            }
        }
        
        return categoryTotals
            .filter { Double($0.value.correct) / Double($0.value.total) < 0.80 }
            .map { $0.key }
            .sorted()
    }
}

// Services/ResultsPersistenceService.swift
final class ResultsPersistenceService {
    private let userDefaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let resultsKey = "simulation_results"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func load() throws -> [SimulationResult] {
        guard let data = userDefaults.data(forKey: resultsKey) else {
            return []
        }
        
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([SimulationResult].self, from: data)
    }
    
    func save(_ results: [SimulationResult]) throws {
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(results)
        userDefaults.set(data, forKey: resultsKey)
    }
    
    func deleteAll() throws {
        userDefaults.removeObject(forKey: resultsKey)
    }
}