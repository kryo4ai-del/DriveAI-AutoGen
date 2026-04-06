// DON'T create separate CrashEvent struct
struct CrashEvent { ... }  // ❌ Duplication

// DO extend existing AnalyticsEvent

// Reuse existing EventQueue<AnalyticsEvent>
private let queue: EventQueue<AnalyticsEvent>