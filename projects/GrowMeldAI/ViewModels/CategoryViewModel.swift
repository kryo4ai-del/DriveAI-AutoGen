import Foundation
import SwiftUI
import Combine

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading = false
    @Published var error: String?

    private let dataService: LocalDataService

    init(dataService: LocalDataService) {
        self.dataService = dataService
    }

    func loadQuestions(for category: Category) {
        isLoading = true
        error = nil
        Task {
            do {
                self.questions = try await dataService.loadQuestions(for: category.id)
            } catch let err {
                self.error = err.localizedDescription
            }
            self.isLoading = false
        }
    }
}