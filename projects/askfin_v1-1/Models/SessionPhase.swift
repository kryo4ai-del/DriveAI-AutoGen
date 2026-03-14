enum SessionPhase: Equatable {
    case brief(previewText: String)
    case question
    case reveal(wasCorrect: Bool, missDistance: Int)
    case summary
}