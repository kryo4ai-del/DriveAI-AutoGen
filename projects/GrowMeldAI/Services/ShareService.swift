import UIKit
import SwiftUI
import os.log

@MainActor
class ShareService: ObservableObject {
    @Published var lastSharedCard: ShareableQuestionCard?
    @Published var isSharing = false
    @Published var shareError: ShareServiceError?
    
    private let seoService: SEOService
    private let imageRenderingService: ImageRenderingService
    private let analyticsService: AnalyticsService?
    private let logger = Logger(subsystem: "com.driveai.share", category: "ShareService")
    
    init(
        seoService: SEOService,
        imageRenderingService: ImageRenderingService,
        analyticsService: AnalyticsService? = nil
    ) {
        self.seoService = seoService
        self.imageRenderingService = imageRenderingService
        self.analyticsService = analyticsService
    }
    
    // MARK: - Share Preparation
    
    /// Prepare share items with error handling
    func prepareShareItems(
        for card: ShareableQuestionCard,
        includeImage: Bool = true
    ) async throws -> [Any] {
        isSharing = true
        defer { isSharing = false }
        
        var items: [Any] = []
        
        // Add text
        if let shareText = card.shareableText {
            items.append(shareText)
        }
        
        // Add image if requested
        if includeImage {
            if let image = await imageRenderingService.generateShareImage(for: card) {
                items.append(image)
            } else if let error = imageRenderingService.renderError {
                throw error
            }
        }
        
        // Add deep link
        items.append(card.deepLink)
        
        lastSharedCard = card
        logger.info("Prepared \(items.count) share items for card: \(card.id)")
        
        return items
    }
    
    // MARK: - Analytics Tracking
    
    /// Track share event with type-safe method
    func trackShare(
        card: ShareableQuestionCard,
        method: ShareMethod
    ) {
        let event = ShareAnalyticsEvent(
            cardID: card.id,
            questionID: card.questionID,
            shareMethod: method,
            timestamp: Date(),
            userID: nil // Privacy-first
        )
        
        analyticsService?.track(event: event)
        logger.info("Tracked share via \(method.rawValue) for card: \(card.id)")
    }
    
    // MARK: - Text Generation
    
    func generateShareText(for question: Question) -> String {
        let deepLink = seoService.generateDeepLink(for: question)
        
        return String(
            format: NSLocalizedString(
                "share.text.template",
                value: "🚗 Can you answer this question? %@\n\nTest yourself: %@\n#DriveAI #DrivingTest",
                comment: "Share text template"
            ),
            question.text,
            deepLink.absoluteString
        )
    }
}

// MARK: - Error Types

enum ShareServiceError: LocalizedError, Identifiable {
    case imageGenerationFailed(String)
    case invalidCard
    case noShareItems
    case unknown(String)
    
    var id: String {
        errorDescription ?? "unknown_error"
    }
    
    var errorDescription: String? {
        switch self {
        case .imageGenerationFailed(let reason):
            return NSLocalizedString(
                "share.error.image_generation",
                value: "Could not generate image: \(reason)",
                comment: "Share image generation error"
            )
        case .invalidCard:
            return NSLocalizedString(
                "share.error.invalid_card",
                value: "Cannot share this card.",
                comment: "Invalid card error"
            )
        case .noShareItems:
            return NSLocalizedString(
                "share.error.no_items",
                value: "Nothing to share.",
                comment: "No share items error"
            )
        case .unknown(let reason):
            return NSLocalizedString(
                "share.error.unknown",
                value: "An error occurred: \(reason)",
                comment: "Unknown share error"
            )
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .imageGenerationFailed:
            return NSLocalizedString(
                "share.recovery.retry",
                value: "Try again or share without image.",
                comment: "Recovery suggestion"
            )
        default:
            return nil
        }
    }
}

// MARK: - Type-Safe Share Method
