import Foundation

class LocalDataService {
    static let shared = LocalDataService()
    private var cachedCategories: [QuestionCategory]? // Caching mechanism

    private init() {}

    func loadCategories(completion: @escaping (Result<[QuestionCategory], Error>) -> Void) {
        if let cachedCategories = cachedCategories {
            completion(.success(cachedCategories))
            return
        }

        DispatchQueue.global().async {
            guard let url = Bundle.main.url(forResource: "Categories", withExtension: "json") else {
                completion(.failure(NSError(domain: "LocalDataServiceError", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found"])))
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let categories = try JSONDecoder().decode([QuestionCategory].self, from: data)
                self.cachedCategories = categories  // Store in cache
                completion(.success(categories))
            } catch {
                completion(.failure(error))
            }
        }
    }
}