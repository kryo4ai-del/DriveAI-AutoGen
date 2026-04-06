import XCTest
@testable import DriveAI

final class UnlockableFeatureTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func testAllFeaturesHaveValidProductIds() {
        // Ensure all features have unique, valid App Store product IDs
        let allFeatures = UnlockableFeature.allCases
        let productIds = allFeatures.map { $0.appStoreProductId }
        
        // Test uniqueness
        XCTAssertEqual(
            productIds.count,
            Set(productIds).count,
            "Product IDs must be unique"
        )
        
        // Test format
        for productId in productIds {
            XCTAssertTrue(
                productId.hasPrefix("com.driveai.purchase."),
                "Product ID must follow bundle format: \(productId)"
            )
        }
    }
    
    func testAllFeaturesHaveLocalizedNames() {
        for feature in UnlockableFeature.allCases {
            let name = feature.displayName
            
            XCTAssertFalse(name.isEmpty, "Display name missing for \(feature)")
            XCTAssertTrue(name.count > 5, "Display name too short: \(name)")
        }
    }
    
    func testAllFeaturesHaveDescriptions() {
        for feature in UnlockableFeature.allCases {
            let description = feature.description
            
            XCTAssertFalse(description.isEmpty, "Description missing for \(feature)")
            XCTAssertTrue(description.count > 20, "Description too short: \(description)")
        }
    }
    
    func testAllFeaturesHaveValidIcons() {
        let validSFSymbols = [
            "repeat.circle.fill",
            "chart.bar.xaxis",
            "list.bullet.rectangle.fill",
            "icloud.and.arrow.up.fill"
        ]
        
        for feature in UnlockableFeature.allCases {
            XCTAssertTrue(
                validSFSymbols.contains(feature.icon),
                "Invalid SF Symbol for \(feature): \(feature.icon)"
            )
        }
    }
    
    // MARK: - Encoding/Decoding
    
    func testFeatureCoding() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for feature in UnlockableFeature.allCases {
            let encoded = try encoder.encode(feature)
            let decoded = try decoder.decode(UnlockableFeature.self, from: encoded)
            
            XCTAssertEqual(feature, decoded, "Coding failed for \(feature)")
        }
    }
    
    func testFeatureHashable() {
        let set = Set(UnlockableFeature.allCases)
        XCTAssertEqual(set.count, UnlockableFeature.allCases.count, "All features should be unique in Set")
    }
    
    // MARK: - Edge Cases
    
    func testFeatureStringRawValuesAreConsistent() {
        let feature = UnlockableFeature.unlimitedExams
        let rawValue = feature.rawValue
        
        XCTAssertEqual(rawValue, "feature.unlimited_exams")
        XCTAssertEqual(UnlockableFeature(rawValue: rawValue), feature)
    }
}