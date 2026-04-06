import SwiftUI
import Foundation

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
                image = await ImageCacheManager.shared.fetch(url)
            }
        }
    }
}

// Simple in-memory cache
final class ImageCacheManager: @unchecked Sendable {
    static let shared = ImageCacheManager()
    
    private var cache: [URL: Image] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    func fetch(_ url: URL) async -> Image? {
        lock.lock()
        if let cached = cache[url] {
            lock.unlock()
            return cached
        }
        lock.unlock()
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            #if canImport(UIKit)
            if let uiImage = UIImage(data: data) {
                let image = Image(uiImage: uiImage)
                lock.lock()
                cache[url] = image
                lock.unlock()
                return image
            }
            #elseif canImport(AppKit)
            if let nsImage = NSImage(data: data) {
                let image = Image(nsImage: nsImage)
                lock.lock()
                cache[url] = image
                lock.unlock()
                return image
            }
            #endif
        } catch {
            // Failed to fetch image
        }
        return nil
    }
}