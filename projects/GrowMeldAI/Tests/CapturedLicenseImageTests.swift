final class CapturedLicenseImageTests: XCTestCase {
    
    func test_initialization_createsValidImage() {
        let metadata = CapturedLicenseMetadata(
            qualityMetrics: CameraQualityMetrics(
                brightness: 0.8, contrast: 0.7, focus: 0.85, alignment: 0.8
            ),
            fileSizeBytes: 50000,
            compressionQuality: 0.8,
            imageHash: "abc123"
        )
        
        let image = CapturedLicenseImage(
            filePath: "/path/to/image.jpg",
            metadata: metadata
        )
        
        XCTAssertNotNil(image.id)
        XCTAssertEqual(image.filePath, "/path/to/image.jpg")
        XCTAssertEqual(image.metadata.fileSizeBytes, 50000)
    }
    
    func test_codableConformance() throws {
        let metadata = CapturedLicenseMetadata(
            qualityMetrics: CameraQualityMetrics(
                brightness: 0.8, contrast: 0.7, focus: 0.85, alignment: 0.8
            ),
            fileSizeBytes: 50000,
            compressionQuality: 0.8,
            imageHash: "hash"
        )
        
        let image = CapturedLicenseImage(filePath: "/path", metadata: metadata)
        
        let encoded = try JSONEncoder().encode(image)
        let decoded = try JSONDecoder().decode(CapturedLicenseImage.self, from: encoded)
        
        XCTAssertEqual(image.id, decoded.id)
        XCTAssertEqual(image.filePath, decoded.filePath)
    }
}