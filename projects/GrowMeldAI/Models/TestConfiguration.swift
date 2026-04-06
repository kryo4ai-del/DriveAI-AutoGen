import Foundation

/// Centralized test configuration and utilities
enum TestConfiguration {
    /// Mock Firestore setup for unit tests
    static func setupMockFirestore() {
        // In production, use Firestore emulator
        // For now, document the pattern:
        // 1. Start emulator: firebase emulators:start
        // 2. Set environment: FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
        // 3. Tests connect to local emulator
    }
    
    /// Common test errors for mocking
    enum TestErrors {
        static let networkError = NSError(
            domain: "FIRFirestoreErrorDomain",
            code: 14,
            userInfo: [NSLocalizedDescriptionKey: "Simulated network error"]
        )
        
        static let decodingError = NSError(
            domain: "NSCocoaErrorDomain",
            code: 4864,
            userInfo: [NSLocalizedDescriptionKey: "Simulated decoding error"]
        )
    }
    
    /// Sample data for testing
    enum SampleData {
        static let validQuestion: [String: Any] = [
            "id": "q1",
            "text": "Was ist eine Ampel?",
            "category": "signs",
            "options": ["A", "B", "C", "D"],
            "correctAnswer": 0
        ]
    }
}