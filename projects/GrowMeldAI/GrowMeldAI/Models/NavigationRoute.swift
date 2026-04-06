enum NavigationRoute: Hashable {
    case examResult(score: Int, total: Int)  // Use primitives, not complex types
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .examResult(let score, let total):
            hasher.combine("examResult")
            hasher.combine(score)
            hasher.combine(total)
        default:
            break
        }
    }
}