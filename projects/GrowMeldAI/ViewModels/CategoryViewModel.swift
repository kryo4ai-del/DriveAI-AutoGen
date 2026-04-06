import Foundation
import Combine
import SwiftUI

struct Question: Identifiable, Codable {
    let id: String
    let text: String
}

struct Category: Identifiable {
    let id: String
    let name: String
}

class LocalDataService {
    func loadQuestions(for categoryId: String) async throws -> [Question] {
        return []
    }
}

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading = false
    @Published var error: String?

    private let dataService: LocalDataService

    init(dataService: LocalDataService = LocalDataService()) {
        self.dataService = dataService
    }

    func loadQuestions(for category: Category) {
        isLoading = true
        Task {
            do {
                self.questions = try await dataService.loadQuestions(for: category.id)
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}