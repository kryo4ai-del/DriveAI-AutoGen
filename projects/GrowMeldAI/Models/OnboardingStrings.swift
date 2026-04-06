import Foundation

/// Centralized localization strings for onboarding flow.
/// Single source of truth for German/English strings.
enum OnboardingStrings {
    
    enum CameraPermission {
        static let notDetermined = NSLocalizedString(
            "permission.camera.notDetermined",
            value: "Kamerazugriff nicht bestimmt",
            comment: "Camera permission: not yet requested"
        )
        
        static let denied = NSLocalizedString(
            "permission.camera.denied",
            value: "Kamerazugriff verweigert",
            comment: "Camera permission: user denied"
        )
        
        static let granted = NSLocalizedString(
            "permission.camera.granted",
            value: "Kamerazugriff gewährt",
            comment: "Camera permission: granted"
        )
        
        static let restricted = NSLocalizedString(
            "permission.camera.restricted",
            value: "Kamerazugriff eingeschränkt",
            comment: "Camera permission: restricted by MDM/parental control"
        )
        
        static let explanation = NSLocalizedString(
            "permission.camera.explanation",
            value: "Ein Foto hilft uns, personalisierte Lernmaterialien für Sie zusammenzustellen.",
            comment: "Why we need camera permission"
        )
        
        static let recoveryDenied = NSLocalizedString(
            "permission.camera.recovery.denied",
            value: "Bitte gewähren Sie Kamerazugriff in den Einstellungen, um Ihr Profil mit einem Foto zu vervollständigen.",
            comment: "Recovery suggestion for denied permission"
        )
    }
    
    enum Validation {
        static let emptyName = NSLocalizedString(
            "validation.error.emptyName",
            value: "Name ist erforderlich",
            comment: "Validation error: empty name"
        )
        
        static let nameTooShort = NSLocalizedString(
            "validation.error.nameTooShort",
            value: "Name muss mindestens \(OnboardingConstraints.minNameLength) Zeichen lang sein",
            comment: "Validation error: name too short"
        )
        
        static let invalidNameCharacters = NSLocalizedString(
            "validation.error.invalidNameCharacters",
            value: "Name enthält ungültige Zeichen. Verwenden Sie Buchstaben, Leerzeichen, Bindestriche und Apostrophe.",
            comment: "Validation error: invalid characters in name"
        )
        
        static let examDateTooSoon = NSLocalizedString(
            "validation.error.examDateTooSoon",
            value: "Prüfungsdatum muss mindestens \(OnboardingConstraints.minimumDaysUntilExam) Tage in der Zukunft liegen",
            comment: "Validation error: exam date too soon"
        )
    }
    
    enum Step {
        static let welcome = NSLocalizedString(
            "onboarding.step.welcome",
            value: "Willkommen",
            comment: "Onboarding step: welcome"
        )
        
        static let permission = NSLocalizedString(
            "onboarding.step.permission",
            value: "Kamerazugriff",
            comment: "Onboarding step: camera permission"
        )
        
        static let profile = NSLocalizedString(
            "onboarding.step.profile",
            value: "Profil",
            comment: "Onboarding step: profile input"
        )
        
        static let photo = NSLocalizedString(
            "onboarding.step.photo",
            value: "Foto",
            comment: "Onboarding step: photo capture"
        )
        
        static let completion = NSLocalizedString(
            "onboarding.step.completion",
            value: "Fertig",
            comment: "Onboarding step: completion"
        )
    }
    
    enum Accessibility {
        static func stepIndicator(current: Int, total: Int) -> String {
            String(format: NSLocalizedString(
                "onboarding.accessibility.step",
                value: "Schritt %d von %d",
                comment: "Accessibility: current step indicator"
            ), current, total)
        }
        
        static func examCountdown(days: Int) -> String {
            String(format: NSLocalizedString(
                "profile.accessibility.examCountdown",
                value: "Prüfung in %d Tagen",
                comment: "Accessibility: days until exam"
            ), days)
        }
    }
}