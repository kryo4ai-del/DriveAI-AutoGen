import Foundation
import SwiftUI

/// ViewModel for Instagram sharing functionality
final class InstagramShareViewModel: ObservableObject {
    @Published var shareResult: Result<Void, Error>?
    @Published var isShowingAlert = false

    private let instagramService: InstagramIntegrationServiceProtocol

    init(instagramService: InstagramIntegrationServiceProtocol = InstagramIntegrationService()) {
        self.instagramService = instagramService
    }

    func shareToInstagram(image: UIImage, caption: String, completion: @escaping (Result<Void, Error>) -> Void) {
        instagramService.shareToInstagramStories(image: image, caption: caption) { [weak self] result in
            DispatchQueue.main.async {
                self?.shareResult = result
                self?.isShowingAlert = true
                completion(result)
            }
        }
    }
}