// Tests/Models/PremiumFeatureTests.swift
import XCTest
@testable import DriveAI

final class PremiumFeatureTests: XCTestCase {
    
    // MARK: - Product ID Mapping
    
    func testAllFeaturesHaveUniqueProductIds() {
        let ids = Set(PremiumFeature.allCases.map(\.productId))
        XCTAssertEqual(ids.count, PremiumFeature.allCases.count)
    }
    
    func testProductIdFormatCorrect() {
        for feature in PremiumFeature.allCases {
            XCTAssertTrue(feature.productId.starts(with: "com.driveai."))
            XCTAssertFalse(feature.productId.contains(" "))
        }
    }
    
    // MARK: - Feature Extraction from ProductID
    
    func testInitFromProductIdSuccess() {
        XCTAssertEqual(
            PremiumFeature(productId: "com.driveai.unlimited_exams"),
            .unlimitedExams
        )
        XCTAssertEqual(
            PremiumFeature(productId: "com.driveai.analytics_plus"),
            .analyticsPlus
        )
        XCTAssertEqual(
            PremiumFeature(productId: "com.driveai.offline_packs"),
            .offlinePacks
        )
    }
    
    func testInitFromProductIdWithoutPrefix() {
        // Edge case: productID without "com.driveai." prefix
        XCTAssertNil(PremiumFeature(productId: "unlimited_exams"))
    }
    
    func testInitFromInvalidProductId() {
        XCTAssertNil(PremiumFeature(productId: "com.other.app.unlimited_exams"))
        XCTAssertNil(PremiumFeature(productId: ""))
        XCTAssertNil(PremiumFeature(productId: "com.driveai.nonexistent"))
    }
    
    // MARK: - Metadata
    
    func testDisplayNamesNotEmpty() {
        for feature in PremiumFeature.allCases {
            XCTAssertFalse(feature.displayName.isEmpty)
            XCTAssertFalse(feature.description.isEmpty)
        }
    }
    
    func testIconsAreValid() {
        for feature in PremiumFeature.allCases {
            let image = UIImage(systemName: feature.icon)
            XCTAssertNotNil(image, "Icon \(feature.icon) not found")
        }
    }
    
    func testFallbackPricesPositive() {
        for feature in PremiumFeature.allCases {
            XCTAssertGreaterThan(feature.fallbackPriceEUR, 0)
        }
    }
    
    // MARK: - Codable
    
    func testFeatureEncodingDecoding() throws {
        let feature = PremiumFeature.unlimitedExams
        let encoded = try JSONEncoder().encode(feature)
        let decoded = try JSONDecoder().decode(PremiumFeature.self, from: encoded)
        XCTAssertEqual(feature, decoded)
    }
    
    func testAllFeaturesEncodable() throws {
        for feature in PremiumFeature.allCases {
            let encoded = try JSONEncoder().encode(feature)
            XCTAssertFalse(encoded.isEmpty)
        }
    }
    
    // MARK: - Hashable
    
    func testFeaturesHashable() {
        let set: Set<PremiumFeature> = [.unlimitedExams, .analyticsPlus, .unlimitedExams]
        XCTAssertEqual(set.count, 2) // Deduped correctly
    }
}