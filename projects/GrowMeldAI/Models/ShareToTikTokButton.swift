// ShareToTikTokButton.swift
import SwiftUI

/// Button component for sharing content to TikTok
/// Uses zero-data-flow approach - user controls all content
struct ShareToTikTokButton: View {
    @State private var isShowingShareSheet = false
    @State private var shareContent: TikTokShareableContent?

    private let deepLinkService: TikTokDeepLinkService
    private let content: TikTokShareableContent

    init(content: TikTokShareableContent, deepLinkService: TikTokDeepLinkService = TikTokDeepLinkService()) {
        self.content = content
        self.deepLinkService = deepLinkService
    }

    var body: some View {
        Button(action: {
            handleShareAction()
        }) {
            Label("Share to TikTok", systemImage: "square.and.arrow.up")
                .labelStyle(.titleAndIcon)
        }
        .sheet(item: $shareContent) { content in
            ActivityView(activityItems: [content.url], applicationActivities: nil)
        }
    }

    private func handleShareAction() {
        // Only open TikTok if installed, otherwise show system share sheet
        if deepLinkService.isTikTokInstalled() {
            let tikTokURL = deepLinkService.deepLink(for: content)
            UIApplication.shared.open(tikTokURL)
        } else {
            // Fallback to system share sheet if TikTok not installed
            shareContent = content
        }
    }
}

// MARK: - ActivityView (UIActivityViewController wrapper)
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}