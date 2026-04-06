import Foundation

struct LocalQuestion: Codable {
    let id: String
    let question: String
    let answers: [String]
    let correctIndex: Int
    let explanation: String
    let category: String
    let difficulty: Int
    let keywords: [String]
}

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        guard let url = self.url(forResource: filename, withExtension: nil) ?? self.url(forResource: (filename as NSString).deletingPathExtension, withExtension: (filename as NSString).pathExtension) else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}