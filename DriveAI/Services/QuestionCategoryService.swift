import Foundation

protocol QuestionCategoryService {
    func fetchQuestionCategories(completion: @escaping ([QuestionCategory]) -> Void)
}

class LocalDataService: QuestionCategoryService {
    func fetchQuestionCategories(completion: @escaping ([QuestionCategory]) -> Void) {
        // Simulate a delay for async behavior in a real scenario
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let categories = [
                QuestionCategory(id: UUID(), name: "Verkehrszeichen", questionCount: 15),
                QuestionCategory(id: UUID(), name: "Vorfahrtsrecht", questionCount: 10),
                QuestionCategory(id: UUID(), name: "Bußgelder", questionCount: 5)
            ]
            completion(categories)
        }
    }
}