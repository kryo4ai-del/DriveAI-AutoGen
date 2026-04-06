import Foundation
enum LocationStrings {
    enum Selection {
        static let title = NSLocalizedString(
            "location.selection.title",
            value: "Wo machst du deine Prüfung?",
            comment: "Location selection screen title"
        )
        static let microBenefit = NSLocalizedString(
            "location.selection.benefit",
            value: "Deine PLZ bestimmt 100% der Prüfungsfragen...",
            comment: "Motivational benefit text"
        )
    }
    
    enum Errors {
        static let bundleNotFound = NSLocalizedString(
            "error.bundle.notfound",
            value: "Location data file not found",
            comment: ""
        )
    }
}