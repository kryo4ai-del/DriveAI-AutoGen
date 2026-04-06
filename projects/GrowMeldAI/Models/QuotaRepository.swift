import Foundation
@MainActor
final class QuotaRepository {
    static let shared = QuotaRepository()
    
    private let fileURL: URL
    
    init(fileURL: URL? = nil) {
        if let fileURL = fileURL {
            self.fileURL = fileURL
        } else {
            // Guaranteed safe path
            let documentsPath = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0]
            self.fileURL = documentsPath.appendingPathComponent("quota_state.json")
        }
    }
}