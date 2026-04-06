enum AnalyticsEvent {
    case appCrashLogged(type: String, severity: String)
    case nonFatalErrorLogged(category: String)
}