@Published var introduction: String = NSLocalizedString("FEATURE_ANNOUNCEMENT_INTRO", comment: "")
@Published var callToAction: String = NSLocalizedString("FEATURE_ANNOUNCEMENT_CALL_TO_ACTION", comment: "")

// ---

@Published var introduction: String = NSLocalizedString("FEATURE_ANNOUNCEMENT_INTRO", comment: "")
@Published var callToAction: String = NSLocalizedString("FEATURE_ANNOUNCEMENT_CALL_TO_ACTION", comment: "")

// ---

// Example changes to be reflected in the ViewModel:
@Published var featureSummary: [String] = [
    "Interaktive Fragen",
    "Statistik-Tracking",
    "Prüfungssimulation",
    "Offline verfügbar",
    "Benutzerfreundliches Design"
]

// ---

// Example featureIcon method
func featureIcon(for feature: String) -> String {
    switch feature {
    case "Interaktive Fragen":
        return "questionmark.circle"
    case "Statistik-Tracking":
        return "chart.bar"
    // Add more icons as necessary
    default:
        return "star.fill"
    }
}

// ---

var localizedIntroduction: String {
    NSLocalizedString("FEATURE_ANNOUNCEMENT_INTRO", comment: "")
}

var localizedCallToAction: String {
    NSLocalizedString("FEATURE_ANNOUNCEMENT_CALL_TO_ACTION", comment: "")
}