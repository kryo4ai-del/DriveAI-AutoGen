import Foundation

final class MockSEOService {
    var generateMetadataCalled = false

    func generateMetadata(for question: String) -> [String: String] {
        generateMetadataCalled = true
        return [
            "title": "Mock Title",
            "description": "Mock Description",
            "keywords": "mock, seo, test"
        ]
    }
}