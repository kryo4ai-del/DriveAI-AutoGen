protocol FirebaseService: Sendable {
    func recordError(_ error: Error) async
    func setCustomValue(_ value: Any, forKey key: String) async
}

final class FirebaseCrashlyticsAdapter: FirebaseService {
    private let crashlytics = Crashlytics.crashlytics()
    // Real implementation
}

struct MockFirebaseService: FirebaseService {
    // Test implementation (no real SDK calls)
}