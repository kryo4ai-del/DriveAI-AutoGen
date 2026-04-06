// Mock for unit tests
class MockSEOService: SEOService {
    var generateMetadataCalled = false
    
    override func generateMetadata(for question: Question) -> MetadataModel {
        generateMetadataCalled = true
        return MetadataModel(/* mock data */)
    }
}

// Preview
#Preview {
    ShareableQuestionCardView(
        question: Question.mockData,
        seoService: MockSEOService(localDataService: .mock),
        shareService: ShareService(seoService: .mock)
    )
}