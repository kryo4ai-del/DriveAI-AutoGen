struct FreemiumTierConfig {
    let questionsPerDay: Int
    let categoriesUnlocked: Int
    let examAttemptsPerDay: Int
    let canAccessWeakAreaDrills: Bool
    let canAccessCustomLearningPath: Bool
    let canAccessOfflineSync: Bool
    
    /// Localized tier name and description (German)
    var a11yTierDescription: (name: String, description: String) {
        switch self {
        case .free:
            return (
                name: "Kostenlos",
                description: "10 Fragen pro Tag, 3 Kategorien verfügbar. Upgrade zu Premium für unbegrenzte Zugriff."
            )
        case .trial:
            return (
                name: "Trial",
                description: "20 Fragen pro Tag, 5 Kategorien, Schwachstellen-Drills aktiviert. Läuft nach 14 Tagen ab."
            )
        case .premium:
            return (
                name: "Premium",
                description: "Unbegrenzte Fragen, alle Kategorien, personalisierte Lernwege, Prüfungssimulation mit Timed-Modus."
            )
        }
    }
    
    /// Feature summary for accessibility (German)
    func a11yFeatureSummary(localizer: Localizing) -> String {
        let features = [
            (questionsPerDay != .max ? 
                localizer.localize("a11y.feature.questions_limit", arguments: ["limit": String(questionsPerDay)])
                : localizer.localize("a11y.feature.questions_unlimited", arguments: [:])),
            (categoriesUnlocked != .max ?
                localizer.localize("a11y.feature.categories_limited", arguments: ["count": String(categoriesUnlocked)])
                : localizer.localize("a11y.feature.categories_all", arguments: [:])),
            (examAttemptsPerDay > 0 ?
                localizer.localize("a11y.feature.exam_attempts", arguments: ["count": String(examAttemptsPerDay)])
                : localizer.localize("a11y.feature.exam_locked", arguments: [:])),
            (canAccessWeakAreaDrills ?
                localizer.localize("a11y.feature.weak_area_drills", arguments: [:])
                : nil),
            (canAccessCustomLearningPath ?
                localizer.localize("a11y.feature.custom_path", arguments: [:])
                : nil),
        ].compactMap { $0 }
        
        return features.joined(separator: ", ")
    }
}

// Localization strings (German):
a11y.feature.questions_limit = "%@ Fragen pro Tag"
a11y.feature.questions_unlimited = "Unbegrenzte Fragen"
a11y.feature.categories_limited = "%@ von vielen Kategorien"
a11y.feature.categories_all = "Alle Kategorien"
a11y.feature.exam_attempts = "%@ Prüfungsversuche pro Tag"
a11y.feature.exam_locked = "Prüfungsmodus nicht verfügbar"
a11y.feature.weak_area_drills = "Schwachstellen-Drills"
a11y.feature.custom_path = "Personalisierter Lernpfad"