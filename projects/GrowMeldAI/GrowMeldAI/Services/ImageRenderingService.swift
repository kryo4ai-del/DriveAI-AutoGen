import UIKit
import SwiftUI
import os.log

@MainActor
class ImageRenderingService: ObservableObject {
    @Published var isRendering = false
    @Published var renderError: ImageRenderingError?
    
    private let logger = Logger(subsystem: "com.driveai.seo", category: "ImageRendering")
    private let renderQueue = DispatchQueue(
        label: "com.driveai.image-rendering",
        qos: .userInitiated
    )
    
    // MARK: - Safe Image Generation
    
    /// Generate share image asynchronously off MainActor
    func generateShareImage(
        for card: ShareableQuestionCard,
        size: CGSize = CGSize(width: 1200, height: 630)
    ) async -> UIImage? {
        isRendering = true
        defer { isRendering = false }
        
        do {
            let image = try await renderImageOffMainThread(card: card, size: size)
            logger.debug("Successfully generated share image for card: \(card.id)")
            return image
        } catch {
            renderError = error as? ImageRenderingError ?? .unknown(error.localizedDescription)
            logger.error("Image generation failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Rendering Logic
    
    private func renderImageOffMainThread(
        card: ShareableQuestionCard,
        size: CGSize
    ) async throws -> UIImage? {
        return try await Task.detached(priority: .userInitiated) { [weak self] () -> UIImage? in
            guard let self = self else { return nil }
            
            // Create hosting controller in background thread
            let hostingController = UIHostingController(
                rootView: ShareCardImageView(card: card)
                    .preferredColorScheme(nil)
                    .environment(\.sizeCategory, .large) // Standard size for rendering
            )
            
            // Setup view hierarchy
            hostingController.view.frame = CGRect(origin: .zero, size: size)
            hostingController.view.backgroundColor = UIColor(.white)
            
            // Force layout
            hostingController.view.layoutIfNeeded()
            
            // Render to image
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { context in
                hostingController.view.drawHierarchy(
                    in: CGRect(origin: .zero, size: size),
                    afterScreenUpdates: false
                )
            }
            
            // Cleanup
            hostingController.view.removeFromSuperview()
            
            return image
        }.value
    }
}

// MARK: - Error Types

enum ImageRenderingError: LocalizedError {
    case renderingFailed(String)
    case invalidCard
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .renderingFailed(let reason):
            return NSLocalizedString(
                "image.error.rendering_failed",
                value: "Could not generate image: \(reason)",
                comment: "Image rendering error"
            )
        case .invalidCard:
            return NSLocalizedString(
                "image.error.invalid_card",
                value: "The share card is invalid.",
                comment: "Invalid card error"
            )
        case .unknown(let reason):
            return NSLocalizedString(
                "image.error.unknown",
                value: "An unexpected error occurred: \(reason)",
                comment: "Unknown image error"
            )
        }
    }
}