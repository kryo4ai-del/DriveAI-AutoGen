private func elaborationPrompt(for question: SessionQuestion) -> String {
    switch question.fehlerpunkteCategory {
    case .vorfahrt:
        return "Wer hätte in dieser Situation Vorfahrt, wenn du aus einer Nebenstraße kommst?"
    case .grundstoff:
        return "Welche allgemeine Regel liegt dieser Situation zugrunde?"
    case .standard:
        return "Was wäre in dieser Situation die sicherste Entscheidung?"
    }
}