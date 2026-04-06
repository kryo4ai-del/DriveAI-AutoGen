import Foundation
import SwiftUI
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var categories: [GrowCategory] = []
    @Published var userProgress: UserProgress?
    @Published var isLoading = false
    @Published var error: AppError?

    let regionManager: RegionManager
    let dataService: QuestionRepository

    init(regionManager: RegionManager, dataService: QuestionRepository) {
        self.regionManager = regionManager
        self.dataService = dataService
    }

    func loadDashboard() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let questions = try await dataService.loadQuestions(for: regionManager.currentRegion)
            self.categories = groupByCategory(questions)
            self.userProgress = await fetchProgress(for: regionManager.currentRegion)
        } catch {
            self.error = AppError(message: error.localizedDescription)
        }
    }

    private func groupByCategory(_ questions: [Question]) -> [GrowCategory] {
        var dict: [String: [Question]] = [:]
        for question in questions {
            dict[question.categoryId, default: []].append(question)
        }
        return dict.map { GrowCategory(id: $0.key, name: $0.key, questions: $0.value) }
            .sorted { $0.name < $1.name }
    }

    private func fetchProgress(for region: String) async -> UserProgress? {
        let key = "userProgress_\(region)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return nil
        }
        return progress
    }
}