import SwiftUI

/// View for sharing content to Instagram
struct InstagramShareView: View {
    @State private var isShowingShareSheet = false
    @State private var shareResult: Result<Void, Error>?
    @State private var isShowingAlert = false

    let image: UIImage
    let caption: String
    let onShareComplete: (Result<Void, Error>) -> Void

    private let instagramService: InstagramIntegrationServiceProtocol

    init(
        image: UIImage,
        caption: String,
        onShareComplete: @escaping (Result<Void, Error>) -> Void,
        instagramService: InstagramIntegrationServiceProtocol = InstagramIntegrationService()
    ) {
        self.image = image
        self.caption = caption
        self.onShareComplete = onShareComplete
        self.instagramService = instagramService
    }

    var body: some View {
        Button(action: shareToInstagram) {
            Label("Share to Instagram", systemImage: "square.and.arrow.up")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .sheet(isPresented: $isShowingShareSheet) {
            ActivityView(activityItems: [image], applicationActivities: nil)
        }
        .alert("Instagram Sharing", isPresented: $isShowingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(shareResult?.errorDescription ?? "Shared successfully!")
        }
    }

    private func shareToInstagram() {
        // First try direct Instagram integration
        instagramService.shareToInstagramStories(image: image, caption: caption) { result in
            if case .failure(let error) = result, (error as? InstagramError) == .appNotInstalled {
                // Fall back to general share sheet if Instagram app not installed
                isShowingShareSheet = true
            }
            shareResult = result
            isShowingAlert = true
            onShareComplete(result)
        }
    }
}

extension Result where Success == Void, Failure == Error {
    var errorDescription: String {
        switch self {
        case .success:
            return "Shared successfully!"
        case .failure(let error):
            return error.localizedDescription
        }
    }
}