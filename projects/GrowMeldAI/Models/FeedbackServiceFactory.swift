// File: Services/Feedback/FeedbackServiceFactory.swift
final class FeedbackServiceFactory {
    static func makeFeedbackService() -> FeedbackService {
        let persistence = LocalFeedbackPersistence()
        return DefaultFeedbackService(
            persistenceService: persistence,
            logger: Logger.shared
        )
    }
}