protocol FallbackDataProvider {
    func getBundledQuestions(category: Category) -> [Question]
    func isBundledDataValid() -> Bool
    func lastBundledUpdate() -> Date
}

class LocalFallbackProvider: FallbackDataProvider {
    // Load from app bundle (JSON or pre-compiled SQLite)
    // Used when:
    // - No network detected at app launch
    // - Sync fails after 3 retries
    // - Exam mode + no connectivity
}