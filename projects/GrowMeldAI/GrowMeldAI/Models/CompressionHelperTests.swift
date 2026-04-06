// Tests/Unit/Services/CompressionHelperTests.swift

import XCTest
@testable import DriveAI

final class CompressionHelperTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func test_compress_roundTrip_small() async throws {
        // Given
        let original = "This is test data for compression".data(using: .utf8)!
        
        // When
        let compressed = try CompressionHelper.compress(original)
        let decompressed = try CompressionHelper.decompress(compressed)
        
        // Then
        XCTAssertEqual(original, decompressed)
    }
    
    func test_compress_roundTrip_large() async throws {
        // Given
        let largeString = String(repeating: "Lorem ipsum dolor sit amet ", count: 1000)
        let original = largeString.data(using: .utf8)!
        
        // When
        let compressed = try CompressionHelper.compress(original)
        let decompressed = try CompressionHelper.decompress(compressed)
        
        // Then
        XCTAssertEqual(original, decompressed)
        XCTAssertLessThan(
            compressed.count,
            original.count,
            "Repetitive data should compress well"
        )
    }
    
    func test_compress_reducesSize_withRepetitiveData() async throws {
        // Given
        let repetitiveData = Data(repeating: 0x00, count: 100_000)
        
        // When
        let compressed = try CompressionHelper.compress(repetitiveData)
        
        // Then
        XCTAssertLess(
            compressed.count,
            repetitiveData.count / 10,
            "Highly repetitive data should compress to < 10% of original"
        )
    }
    
    func test_compress_preservesRandomData() async throws {
        // Given
        var randomBytes = [UInt8](repeating: 0, count: 10_000)
        for i in 0..<randomBytes.count {
            randomBytes[i] = UInt8.random(in: 0...255)
        }
        let randomData = Data(randomBytes)
        
        // When
        let compressed = try CompressionHelper.compress(randomData)
        
        // Then
        // Random data typically doesn't compress well
        XCTAssertGreater(
            compressed.count,
            randomData.count * 99 / 100,
            "Random data shouldn't compress significantly"
        )
    }
    
    // MARK: - Edge Cases
    
    func test_compress_emptyData() async throws {
        // Given
        let emptyData = Data()
        
        // When
        let compressed = try CompressionHelper.compress(emptyData)
        
        // Then
        XCTAssertGreaterThan(compressed.count, 0, "Even empty data has compression overhead")
    }
    
    func test_decompress_wrongEstimatedSize() async throws {
        // Given
        let original = Data(repeating: 0xAA, count: 50_000)
        let compressed = try CompressionHelper.compress(original)
        
        // When
        let decompressed = try CompressionHelper.decompress(
            compressed,
            estimatedSize: 100_000  // Different size
        )
        
        // Then
        XCTAssertEqual(original, decompressed)
    }
    
    func test_decompress_buffer_expansion_needed() async throws {
        // Given
        let original = String(repeating: "x", count: 500_000).data(using: .utf8)!
        let compressed = try CompressionHelper.compress(original)
        
        // When - decompress with small initial buffer
        let decompressed = try CompressionHelper.decompress(
            compressed,
            estimatedSize: 1000  // Too small
        )
        
        // Then
        XCTAssertEqual(original, decompressed)
    }
    
    // MARK: - Failure Scenarios
    
    func test_decompress_corruptedData_throws() async throws {
        // Given
        let corruptedData = Data([0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00])
        
        // When / Then
        XCTAssertThrowsError(
            try CompressionHelper.decompress(corruptedData)
        ) { error in
            let backupError = error as? BackupError
            XCTAssertEqual(
                backupError,
                .deserializationFailed("ZLIB decompression failed")
            )
        }
    }
    
    func test_decompress_truncatedData_throws() async throws {
        // Given
        let original = Data(repeating: 0xFF, count: 10_000)
        var compressed = try CompressionHelper.compress(original)
        compressed.removeLast(100)  // Truncate
        
        // When / Then
        XCTAssertThrowsError(
            try CompressionHelper.decompress(compressed)
        )
    }
}