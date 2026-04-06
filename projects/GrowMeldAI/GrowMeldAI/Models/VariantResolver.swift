@MainActor
final class VariantResolver: ObservableObject {
    @Published var activeVariants: [String: String] = [:]
    
    func resolveVariant(_ experimentId: String) -> String {
        activeVariants[experimentId] ?? "default"
    }
}

// In View
@StateObject var variantResolver = VariantResolver(...)