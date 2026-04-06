import XCTest
@testable import DriveAI

final class ExperimentTests: XCTestCase {
    
    func testExperimentIsRunning_ActiveAndWithinDateRange() {
        let now = Date()
        let experiment = Experiment(
            id: "exp1",
            name: "Test",
            description: nil,
            active: true,
            variants: [
                Variant(id: "a", weight: 0.5),
                Variant(id: "b", weight: 0.5)
            ],
            startDate: now.addingTimeInterval(-3600),  // 1 hour ago
            endDate: now.addingTimeInterval(3600),     // 1 hour from now
            metadata: nil
        )
        
        XCTAssertTrue(experiment.isRunning)
    }
    
    func testExperimentNotRunning_Inactive() {
        let experiment = Experiment(
            id: "exp1",
            name: "Test",
            description: nil,
            active: false,  // ← Inactive
            variants: [Variant(id: "a", weight: 1.0)],
            startDate: Date(),
            endDate: nil,
            metadata: nil
        )
        
        XCTAssertFalse(experiment.isRunning)
    }
    
    func testExperimentNotRunning_PastEndDate() {
        let now = Date()
        let experiment = Experiment(
            id: "exp1",
            name: "Test",
            description: nil,
            active: true,
            variants: [Variant(id: "a", weight: 1.0)],
            startDate: now.addingTimeInterval(-7200),
            endDate: now.addingTimeInterval(-3600),  // ← Ended
            metadata: nil
        )
        
        XCTAssertFalse(experiment.isRunning)
    }
    
    func testExperimentNotRunning_FutureStartDate() {
        let now = Date()
        let experiment = Experiment(
            id: "exp1",
            name: "Test",
            description: nil,
            active: true,
            variants: [Variant(id: "a", weight: 1.0)],
            startDate: now.addingTimeInterval(3600),  // ← Hasn't started
            endDate: nil,
            metadata: nil
        )
        
        XCTAssertFalse(experiment.isRunning)
    }
    
    func testExperimentCoding_EncodesAndDecodes() throws {
        let original = Experiment(
            id: "exp1",
            name: "Button Color",
            description: "Test red vs blue buttons",
            active: true,
            variants: [
                Variant(id: "red", weight: 0.5, config: ["color": .string("red")]),
                Variant(id: "blue", weight: 0.5, config: ["color": .string("blue")])
            ],
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            metadata: ["priority": "high"]
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Experiment.self, from: encoded)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.variants.count, decoded.variants.count)
    }
}