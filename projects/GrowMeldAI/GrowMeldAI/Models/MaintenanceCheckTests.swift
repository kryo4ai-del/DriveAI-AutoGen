import XCTest
@testable import DriveAI

final class MaintenanceCheckTests: XCTestCase {
    
    // MARK: - Initialization
    
    func test_init_createsCheckWithDefaults() {
        let check = MaintenanceCheck(
            type: .staleCategoryAlert,
            severity: .high,
            suggestedAction: "Test action"
        )
        
        XCTAssertNotNil(check.id)
        XCTAssertEqual(check.type, .staleCategoryAlert)
        XCTAssertEqual(check.severity, .high)
        XCTAssertFalse(check.isResolved)
        XCTAssertTrue(check.affectedCategories.isEmpty)
    }
    
    func test_init_acceptsAllParameters() {
        let now = Date()
        let categories = ["Vorfahrtsregeln", "Verkehrszeichen"]
        let metadata = ["key": "value"]
        
        let check = MaintenanceCheck(
            type: .lowCompletionRate,
            severity: .medium,
            detectedAt: now,
            affectedCategories: categories,
            suggestedAction: "Improve completion",
            isResolved: true,
            metadata: metadata
        )
        
        XCTAssertEqual(check.detectedAt, now)
        XCTAssertEqual(check.affectedCategories, categories)
        XCTAssertTrue(check.isResolved)
        XCTAssertEqual(check.metadata, metadata)
    }
    
    // MARK: - Codable
    
    func test_maintenanceCheck_encodesAndDecodesCorrectly() throws {
        let original = MaintenanceCheck(
            type: .cacheCleanup,
            severity: .low,
            affectedCategories: ["Cache"],
            suggestedAction: "Clean old data",
            metadata: ["sizeBytes": "104857600"]
        )
        
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MaintenanceCheck.self, from: encoded)
        
        XCTAssertEqual(original, decoded)
    }
    
    func test_maintenanceCheck_decodesLegacyFormat() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "type": "staleCategoryAlert",
            "severity": 3,
            "detectedAt": "2026-04-02T10:00:00Z",
            "affectedCategories": ["Verkehrszeichen"],
            "suggestedAction": "Übe Verkehrszeichen",
            "isResolved": false,
            "metadata": {}
        }
        """.data(using: .utf8)!
        
        let decoded = try JSONDecoder().decode(MaintenanceCheck.self, from: json)
        XCTAssertEqual(decoded.type, .staleCategoryAlert)
        XCTAssertEqual(decoded.severity, .high)
    }
    
    // MARK: - Equatable
    
    func test_maintenanceCheck_equatableComparesAllFields() {
        let id = UUID()
        let date = Date()
        
        let check1 = MaintenanceCheck(
            id: id,
            type: .streakReset,
            severity: .high,
            detectedAt: date,
            affectedCategories: ["A"],
            suggestedAction: "Test",
            isResolved: false
        )
        
        let check2 = MaintenanceCheck(
            id: id,
            type: .streakReset,
            severity: .high,
            detectedAt: date,
            affectedCategories: ["A"],
            suggestedAction: "Test",
            isResolved: false
        )
        
        XCTAssertEqual(check1, check2)
    }
    
    func test_maintenanceCheck_notEqualWhenResolvedStatusDiffers() {
        let id = UUID()
        let date = Date()
        
        let check1 = MaintenanceCheck(
            id: id,
            type: .staleCategoryAlert,
            severity: .medium,
            detectedAt: date,
            suggestedAction: "Test",
            isResolved: false
        )
        
        let check2 = MaintenanceCheck(
            id: id,
            type: .staleCategoryAlert,
            severity: .medium,
            detectedAt: date,
            suggestedAction: "Test",
            isResolved: true  // Different
        )
        
        XCTAssertNotEqual(check1, check2)
    }
    
    // MARK: - Edge Cases
    
    func test_maintenanceCheck_handlesEmptyMetadata() {
        let check = MaintenanceCheck(
            type: .outdatedQuestionCatalog,
            severity: .low,
            suggestedAction: "Update",
            metadata: [:]
        )
        
        XCTAssertTrue(check.metadata.isEmpty)
    }
    
    func test_maintenanceCheck_handlesUmlautsInAction() {
        let action = "Übe *Ä* und *Ö* und *Ü*"
        
        let check = MaintenanceCheck(
            type: .staleCategoryAlert,
            severity: .medium,
            suggestedAction: action
        )
        
        XCTAssertEqual(check.suggestedAction, action)
        
        // Round-trip
        let encoded = try! JSONEncoder().encode(check)
        let decoded = try! JSONDecoder().decode(MaintenanceCheck.self, from: encoded)
        XCTAssertEqual(decoded.suggestedAction, action)
    }
    
    func test_maintenanceCheck_handlesMultipleAffectedCategories() {
        let categories = ["Vorfahrtsregeln", "Verkehrszeichen", "Bußgelder", "Verhalten im Straßenverkehr"]
        
        let check = MaintenanceCheck(
            type: .lowCompletionRate,
            severity: .high,
            affectedCategories: categories,
            suggestedAction: "Multiple categories"
        )
        
        XCTAssertEqual(check.affectedCategories.count, 4)
        XCTAssertEqual(check.affectedCategories, categories)
    }
    
    func test_maintenanceCheck_metadata_preservesSpecialCharacters() throws {
        let metadata = [
            "note": "Ümlaut tëst",
            "emoji": "🔥",
            "json": "{\"nested\": \"value\"}"
        ]
        
        let check = MaintenanceCheck(
            type: .streakReset,
            severity: .high,
            suggestedAction: "Test",
            metadata: metadata
        )
        
        let encoded = try JSONEncoder().encode(check)
        let decoded = try JSONDecoder().decode(MaintenanceCheck.self, from: encoded)
        
        XCTAssertEqual(decoded.metadata, metadata)
    }
}