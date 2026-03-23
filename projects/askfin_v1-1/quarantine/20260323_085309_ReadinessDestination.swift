import Foundation

enum ReadinessDestination: Hashable, Sendable {
    case categoryDetail(CategoryReadiness)
    case categoryDrill(String) // categoryId
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .categoryDetail(let category):
            hasher.combine("detail")
            hasher.combine(category.id)
        case .categoryDrill(let categoryId):
            hasher.combine("drill")
            hasher.combine(categoryId)
        }
    }
    
    static func == (lhs: ReadinessDestination, rhs: ReadinessDestination) -> Bool {
        switch (lhs, rhs) {
        case (.categoryDetail(let l), .categoryDetail(let r)):
            return l.id == r.id
        case (.categoryDrill(let l), .categoryDrill(let r)):
            return l == r
        default:
            return false
        }
    }
}