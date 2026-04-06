struct ConsentContext: Identifiable {
    let id: String // "exam_center_locator"
    let purpose: String // User-facing explanation
    let useCase: LocationDataModel.UseCase
    let privacyNoticeUrl: URL?
    let retentionDays: Int = 30
}

// Usage in View:
@EnvironmentKey var consentContext: ConsentContext

Text(consentContext.purpose)
    .accessibilityHint("Location will be deleted after \(consentContext.retentionDays) days")