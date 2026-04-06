import Foundation
final class LocalFeedbackPersistence: FeedbackPersistenceService {
    private let fileManager: FileManager
    private let feedbackURL: URL
    
    init(
        fileManager: FileManager = .default,
        feedbackURL: URL? = nil
    ) {
        self.fileManager = fileManager
        
        if let providedURL = feedbackURL {
            self.feedbackURL = providedURL
        } else {
            let documentsPath = fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first ?? FileManager.default.temporaryDirectory
            
            self.feedbackURL = documentsPath.appendingPathComponent("feedback.json")
        }
    }
}