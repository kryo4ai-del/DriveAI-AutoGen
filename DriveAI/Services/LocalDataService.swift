import Foundation

class LocalDataService {
    func loadQuestions(from filename: String) -> Result<[Question], Error> {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            return .failure(NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found."]))
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: data)
            return .success(questions)
        } catch {
            return .failure(error)
        }
    }
}