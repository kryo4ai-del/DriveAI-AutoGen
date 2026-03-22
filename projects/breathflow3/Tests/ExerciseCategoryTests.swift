// Tests/ExerciseCategoryTests.swift
import XCTest
@testable import BreathFlow3

class ExerciseCategoryTests: XCTestCase {

    func testCategoryDisplayName() {
        XCTAssertEqual(ExerciseCategory.roadSigns.displayName, "Road Signs")
        XCTAssertEqual(ExerciseCategory.trafficRules.displayName, "Traffic Rules")
        XCTAssertEqual(ExerciseCategory.safetyProcedures.displayName, "Safety Procedures")
    }

    func testCategoryIcon() {
        XCTAssertEqual(ExerciseCategory.roadSigns.icon, "triangle.fill")
        XCTAssertEqual(ExerciseCategory.trafficRules.icon, "car.fill")
        XCTAssertEqual(ExerciseCategory.safetyProcedures.icon, "checklist")
    }

    func testCategoryCaseIterable() {
        let allCases = ExerciseCategory.allCases
        XCTAssertEqual(allCases.count, 5)
        XCTAssert(allCases.contains(.roadSigns))
    }

    func testCategoryIdentifiable() {
        XCTAssertEqual(ExerciseCategory.roadSigns.id, "roadSigns")
        XCTAssertEqual(ExerciseCategory.trafficRules.id, "trafficRules")
    }
}
