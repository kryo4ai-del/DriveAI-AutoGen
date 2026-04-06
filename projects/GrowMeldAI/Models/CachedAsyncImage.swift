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
                image = await ImageCache.shared.fetch(url)
            }
        }
    }
}

// Simple in-memory cache