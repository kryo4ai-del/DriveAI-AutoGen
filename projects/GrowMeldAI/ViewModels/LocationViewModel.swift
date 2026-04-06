@MainActor
final class LocationViewModel: ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: UserLocationContext?
    @Published var error: LocationError?
    @Published var isLoading = false
    
    // ✅ A11y helpers
    var accessibilityPermissionHint: String {
        switch authorizationStatus {
        case .notDetermined:
            return NSLocalizedString(
                "location.a11y.status.not_determined",
                value: "Standortberechtigung wurde noch nicht angefordert",
                comment: "VoiceOver hint"
            )
        case .denied, .restricted:
            return NSLocalizedString(
                "location.a11y.status.denied",
                value: "Standortberechtigung ist deaktiviert. Aktivieren Sie es in Einstellungen.",
                comment: "VoiceOver hint for denied permission"
            )
        case .authorizedWhenInUse, .authorizedAlways:
            let regionName = currentLocation?.region.localizedName ?? "unbekannt"
            return NSLocalizedString(
                "location.a11y.status.authorized",
                value: "Standort aktiviert. Aktuelle Region: \(regionName)",
                comment: "VoiceOver hint for authorized"
            )
        @unknown default:
            return ""
        }
    }
    
    var accessibilityLoadingValue: String? {
        isLoading ? NSLocalizedString(
            "location.a11y.loading",
            value: "Standort wird ermittelt...",
            comment: "Loading announcement"
        ) : nil
    }
}