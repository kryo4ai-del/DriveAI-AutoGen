import Foundation
import Combine

/// Protocol defining the contract for Instagram integration services
protocol InstagramIntegrationServiceProtocol {
    /// Shares content to Instagram Stories
    /// - Parameters:
    ///   - image: The image to share
    ///   - caption: Optional caption text
    ///   - completion: Completion handler with Result
    func shareToInstagramStories(image: UIImage, caption: String?, completion: @escaping (Result<Void, Error>) -> Void)

    /// Shares content to Instagram Feed
    /// - Parameters:
    ///   - image: The image to share
    ///   - caption: Optional caption text
    ///   - completion: Completion handler with Result
    func shareToInstagramFeed(image: UIImage, caption: String?, completion: @escaping (Result<Void, Error>) -> Void)
}

/// Concrete implementation of Instagram integration service
final class InstagramIntegrationService: InstagramIntegrationServiceProtocol {
    private enum Constants {
        static let instagramStoriesURL = URL(string: "instagram-stories://share")!
        static let instagramFeedURL = URL(string: "instagram://app")!
    }

    func shareToInstagramStories(image: UIImage, caption: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard UIApplication.shared.canOpenURL(Constants.instagramStoriesURL) else {
            completion(.failure(InstagramError.appNotInstalled))
            return
        }

        // Instagram Stories requires specific URL scheme with image data
        var components = URLComponents(url: Constants.instagramStoriesURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "source_application", value: Bundle.main.bundleIdentifier),
            URLQueryItem(name: "attachment_url", value: "data:image/jpeg;base64,\(image.jpegData(compressionQuality: 1.0)?.base64EncodedString() ?? "")")
        ]

        guard let url = components?.url else {
            completion(.failure(InstagramError.invalidURL))
            return
        }

        UIApplication.shared.open(url) { success in
            completion(success ? .success(()) : .failure(InstagramError.sharingFailed))
        }
    }

    func shareToInstagramFeed(image: UIImage, caption: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard UIApplication.shared.canOpenURL(Constants.instagramFeedURL) else {
            completion(.failure(InstagramError.appNotInstalled))
            return
        }

        // Save image to temporary directory for Instagram to access
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("instagram_share.jpg")

        do {
            try image.jpegData(compressionQuality: 1.0)?.write(to: tempURL)
            let documentInteractionController = UIDocumentInteractionController(url: tempURL)
            documentInteractionController.delegate = self
            documentInteractionController.annotation = caption.map { ["InstagramCaption": $0] }
            documentInteractionController.presentOpenInMenu(from: .zero, in: .zero, animated: true)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}

extension InstagramIntegrationService: UIDocumentInteractionControllerDelegate {
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        try? FileManager.default.removeItem(at: controller.url)
    }

    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        try? FileManager.default.removeItem(at: controller.url)
    }
}

/// Custom error type for Instagram integration
enum InstagramError: Error, LocalizedError {
    case appNotInstalled
    case invalidURL
    case sharingFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .appNotInstalled:
            return "Instagram app is not installed"
        case .invalidURL:
            return "Failed to create sharing URL"
        case .sharingFailed:
            return "Failed to share to Instagram"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}