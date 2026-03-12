import Foundation
struct BlocklistItem: Identifiable, Equatable {
    let id: UUID
    let question: String
    let reason: String
}