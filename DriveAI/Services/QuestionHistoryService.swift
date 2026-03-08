import Foundation
import UIKit

class QuestionHistoryService {

    private let storageKey = "driveai_question_history"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Save
    func save(_ entry: QuestionHistoryEntry) {
        var history = fetch()
        history.insert(entry, at: 0) // newest first
        if let data = try? encoder.encode(history) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Fetch
    func fetch() -> [QuestionHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let history = try? decoder.decode([QuestionHistoryEntry].self, from: data) else {
            return []
        }
        return history
    }

    // MARK: - Clear
    func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - Weakness analysis

    func analyzeWeaknessPatterns() -> [WeaknessCategory] {
        WeaknessAnalysisService().analyzeWeaknessPatterns(from: fetch())
    }

    func topWeakCategories(limit: Int = 3) -> [WeaknessCategory] {
        WeaknessAnalysisService().topWeakCategories(from: fetch(), limit: limit)
    }

    // MARK: - Image compression
    /// Scale image to max 300pt width, compress to JPEG 0.4 quality (~20-50KB)
    func compressImage(_ image: UIImage) -> Data? {
        let maxDimension: CGFloat = 300
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let scaled = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return scaled.jpegData(compressionQuality: 0.4)
    }
}
