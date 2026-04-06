// Tests/Unit/Domain/Models/CategoryTests.swift

import XCTest
@testable import DriveAI

final class CategoryTests: XCTestCase {
    
    func test_category_initialization() {
        let category = Category(
            id: "traffic_signs",
            name: "Verkehrszeichen",
            description: "German traffic signs",
            iconName: "sign.questionmark",
            order: 1
        )
        
        XCTAssertEqual(category.id, "traffic_signs")
        XCTAssertEqual(category.name, "Verkehrszeichen")
    }
    
    func test_category_codable() throws {
        let category = Category(
            id: "right_of_way",
            name: "Vorfahrtsregeln",
            description: "Rules for priority",
            iconName: "arrow.up",
            order: 2
        )
        
        let data = try JSONEncoder().encode(category)
        let decoded = try JSONDecoder().decode(Category.self, from: data)
        
        XCTAssertEqual(category.id, decoded.id)
    }
}