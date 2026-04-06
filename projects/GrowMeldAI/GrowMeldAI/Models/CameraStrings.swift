// Resources/Strings+Camera.swift
enum CameraStrings {
    enum Permission {
        static let title = NSLocalizedString(
            "camera.permission.title",
            value: "Kamera-Zugriff benötigt",
            comment: "Title for camera permission request"
        )
        
        static let description = NSLocalizedString(
            "camera.permission.description",
            value: "Wir benötigen Zugriff auf deine Kamera, um Dokumente zu scannen und dich zu verifizieren. Deine Daten werden nicht gespeichert oder übertragen.",
            comment: "Description for camera permission"
        )
        
        static let allow = NSLocalizedString(
            "camera.permission.allow",
            value: "Kamera-Zugriff erlauben",
            comment: "Button: allow camera access"
        )
        
        static let later = NSLocalizedString(
            "camera.permission.later",
            value: "Später",
            comment: "Button: dismiss for now"
        )
    }
    
    enum Error {
        static let denied = NSLocalizedString(
            "camera.error.denied",
            value: "Kamera-Zugriff verweigert",
            comment: "Error message when camera access is denied"
        )
        
        static let restricted = NSLocalizedString(
            "camera.error.restricted",
            value: "Kamera-Zugriff ist eingeschränkt",
            comment: "Error message when camera is restricted"
        )
        
        static let unavailable = NSLocalizedString(
            "camera.error.unavailable",
            value: "Kamera nicht verfügbar",
            comment: "Error message when no camera hardware"
        )
    }
}

// Usage in code:
Text(CameraStrings.Permission.title)
Text(CameraStrings.Error.denied)