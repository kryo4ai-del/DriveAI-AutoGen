enum ExamPhase {
    case exploration    // 45+ days: "Build broad foundation"
    case strategic      // 15–44 days: "Focus on weak areas"
    case intensive      // 3–14 days: "Daily targeted review"
    case maintenance    // <3 days: "Light refresher only"
}

var motivationalMessage: String {
    switch examPhase {
    case .exploration:
        return "Du hast Zeit — baue eine solide Grundlage. Starten: \(weakestCategory.name)"
    case .strategic:
        return "Mittlere Phase: Konzentriere dich auf diese 3 Kategorien: \(top3Weak.joined)"
    case .intensive:
        return "Endspurt! 2–3 kurze Prüfungen täglich bis zur Sicherheit."
    case .maintenance:
        return "Fast geschafft. Morgen 1 Prüfung — nicht überanstrengen!"
    }
}