import SwiftUI
import Foundation

actor ImageCache {
    static let shared = ImageCache()
    private var cache: [URL: Image] = [:]

    func fetch(_ url: URL) async -> Image? {
        if let cached = cache[url] {
            return cached
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        let image = Image(uiImage: uiImage)
        cache[url] = image
        return image
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    @State private var image: Image?

    var body: some View {
        Group {
            if let image = image {
                image.resizable()
            } else {
                ProgressView()
            }
        }
        .task {
            if let url = url {
                image = await ImageCache.shared.fetch(url)
            }
        }
    }
}