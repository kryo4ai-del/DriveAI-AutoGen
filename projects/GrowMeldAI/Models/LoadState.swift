@Published private(set) var loadState: LoadState = .loading

enum LoadState: Equatable {
    case loading
    case ready
    case failed(message: String)  // ← User won't hear error without view integration
}