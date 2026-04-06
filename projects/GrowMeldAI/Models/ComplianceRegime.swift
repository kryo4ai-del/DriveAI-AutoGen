enum ComplianceRegime {
    case gdprOnly              // DACH-only distribution
    case coppaOnly             // US-only distribution
    case coppaAndGdpr          // Global distribution
    case coppaWithGdprPrimacy  // EU users exempt from COPPA
}

// Determines at app-launch time based on:
// 1. User's detected location (IP geolocation)
// 2. App Store region distribution settings
// 3. User's stated location in onboarding