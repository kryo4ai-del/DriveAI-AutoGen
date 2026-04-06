struct AccessibleBreadcrumb: Sendable {
    let message: String
    let accessibilityLabel: String  // VoiceOver-friendly description
    let level: BreadcrumbLevel
    let timestamp: Date
}

// Usage in ViewModel
service.recordBreadcrumb(
    AccessibleBreadcrumb(
        message: "User answered question \(id)",
        accessibilityLabel: "User submitted answer to \(question.text)",  // Full question text
        level: .info,
        timestamp: Date()
    )
)