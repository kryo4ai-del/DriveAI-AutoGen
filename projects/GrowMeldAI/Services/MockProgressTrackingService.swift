final class MockProgressTrackingService: ProgressTrackingServiceProtocol {
    func calculateAccuracy(categoryId: String?) -> Double {
        return 0.75 // ⚠️ Hardcoded, doesn't match protocol
    }
}