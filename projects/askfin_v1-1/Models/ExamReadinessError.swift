// 1. Define proper error types
enum ExamReadinessError: LocalizedError, Codable {
    case noCategoryData(reason: String)
    case corruptTrendData(categoryId: String)
    case persistenceFailure(String)
    case invalidCategoryId(String)
    
    var errorDescription: String? {
        switch self {
        case .noCategoryData(let reason):
            return "Kategoriendaten nicht verfügbar: \(reason)"
        case .corruptTrendData(let catId):
            return "Beschädigte Trenddaten für \(catId)"
        case .persistenceFailure(let msg):
            return "Speicherfehler: \(msg)"
        case .invalidCategoryId(let id):
            return "Ungültige Kategorie-ID: \(id)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noCategoryData:
            return "Versuchen Sie es später erneut"
        case .corruptTrendData:
            return "Löschen Sie den App-Cache und starten Sie neu"
        case .persistenceFailure:
            return "Überprüfen Sie den verfügbaren Speicherplatz"
        case .invalidCategoryId:
            return "Kontaktieren Sie Support"
        }
    }
}

// 2. Refactor service method
@MainActor
class ExamReadinessService: ExamReadinessServiceProtocol {
    // ...
    
    func getCategoryReadiness() async throws -> [CategoryReadiness] {
        let categories = try await dataService.fetchAllCategories()
        
        guard !categories.isEmpty else {
            throw ExamReadinessError.noCategoryData(reason: "0 Kategorien in DB")
        }
        
        return try await withThrowingTaskGroup(
            of: CategoryReadiness.self,
            returning: [CategoryReadiness].self
        ) { group in
            for category in categories {
                // NO [weak self] needed — service is singleton
                group.addTask {
                    try await self.readinessForCategory(category)
                }
            }
            
            var results: [CategoryReadiness] = []
            for try await result in group {
                results.append(result)
            }
            
            guard !results.isEmpty else {
                throw ExamReadinessError.noCategoryData(reason: "Keine Ergebnisse aus TaskGroup")
            }
            
            return results.sorted { $0.name < $1.name }
        }
    }
    
    private func readinessForCategory(_ category: Category) async throws -> CategoryReadiness {
        guard !category.id.isEmpty else {
            throw ExamReadinessError.invalidCategoryId("empty")
        }
        
        do {
            let stats = try await progressService.getCategoryStatistics(categoryId: category.id)
            let average = stats.totalQuestions > 0
                ? Double(stats.correctAnswers) / Double(stats.totalQuestions)
                : 0.0
            let strength = strengthForScore(average)
            
            return CategoryReadiness(
                id: category.id,
                name: category.name,
                icon: iconForCategory(category.id),
                totalQuestions: stats.totalQuestions,
                correctAnswers: stats.correctAnswers,
                averageScore: average,
                lastStudied: stats.lastAttemptDate,
                strength: strength
            )
        } catch {
            // Wrap underlying error with context
            throw ExamReadinessError.noCategoryData(
                reason: "Fehler für \(category.id): \(error.localizedDescription)"
            )
        }
    }
}

// 3. In ViewModel, handle specific errors
@MainActor
class ExamReadinessViewModel: ObservableObject {
    func loadReadiness() {
        Task {
            do {
                let score = try await service.calculateOverallReadiness()
                self.readinessScore = score
            } catch let error as ExamReadinessError {
                // Handle specific error types
                self.error = error.errorDescription ?? "Unbekannter Fehler"
                self.recoveryHint = error.recoverySuggestion
                self.showRetryButton = self.isTransientError(error)
            } catch {
                self.error = "Unerwarteter Fehler"
                self.showRetryButton = false
            }
        }
    }
    
    private func isTransientError(_ error: ExamReadinessError) -> Bool {
        switch error {
        case .noCategoryData, .persistenceFailure:
            return true // Retry might help
        case .corruptTrendData, .invalidCategoryId:
            return false // Won't be fixed by retry
        }
    }
}