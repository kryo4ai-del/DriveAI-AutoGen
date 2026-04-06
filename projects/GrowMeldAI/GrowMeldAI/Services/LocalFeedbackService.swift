// Services/LocalFeedbackService.swift
final class LocalFeedbackService: FeedbackService {
    private let fileStorageService: FileStorageService
    private let logger: LoggingService
    private let storageKey = "feedback_cache"
    
    init(
        fileStorageService: FileStorageService = .shared,
        logger: LoggingService = .shared
    ) {
        self.fileStorageService = fileStorageService
        self.logger = logger
    }
    
    func submit(feedback: FeedbackModel) async throws {
        // Validate before storage
        guard !feedback.text.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw FeedbackError.validationFailed("Feedback text cannot be empty")
        }
        
        guard feedback.text.count <= 500 else {
            throw FeedbackError.validationFailed("Feedback exceeds 500 characters")
        }
        
        // Load existing feedbacks (thread-safe)
        var feedbacks = try await retrieveAllFeedback()
        feedbacks.append(feedback)
        
        // Persist with error handling
        do {
            try fileStorageService.save(
                feedbacks,
                toFile: storageKey,
                inDirectory: .documentDirectory
            )
            logger.log("Feedback submitted: \(feedback.id)")
        } catch {
            logger.error("Failed to save feedback: \(error)")
            throw FeedbackError.storageFailed(error.localizedDescription)
        }
    }
    
    func retrieveAllFeedback() async throws -> [FeedbackModel] {
        do {
            let data = try fileStorageService.load(
                fromFile: storageKey,
                inDirectory: .documentDirectory,
                as: [FeedbackModel].self
            )
            return data
        } catch {
            logger.warning("No feedback cache found: \(error)")
            return []
        }
    }
}