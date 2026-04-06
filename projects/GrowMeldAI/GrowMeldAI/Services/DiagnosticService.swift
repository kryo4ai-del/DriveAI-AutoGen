// ❌ Couples domain to infrastructure
class DiagnosticService {
    let database: LocalDataService
    let analytics: AnalyticsService
}