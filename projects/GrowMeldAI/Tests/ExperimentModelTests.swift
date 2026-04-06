import XCTest
@testable import DriveAIDomain

class ExperimentModelTests: XCTestCase {
    
    // MARK: - Initialization Happy Path
    
    func test_initWithValidParameters_succeeds() throws {
        let variant = try Variant(
            experimentID: "exp1",
            name: "Control",
            allocationPercentage: 50.0,
            configuration: .init()
        )
        
        let exp = try Experiment(
            name: "Answer Layout Test",
            description: "Testing vertical vs horizontal",
            hypothesis: "Vertical buttons improve answer speed",
            variants: [
                variant,
                try Variant(
                    experimentID: "exp1",
                    name: "Treatment",
                    allocationPercentage: 50.0,
                    configuration: .init(answerLayout: .horizontal)
                )
            ],
            successMetrics: [.correctAnswerRate, .averageTimeToAnswer],
            startDate: Date(),
            endDate: Date(timeIntervalSinceNow: 86400 * 7) // 7 days
        )
        
        XCTAssertEqual(exp.name, "Answer Layout Test")
        XCTAssertEqual(exp.variants.count, 2)
        XCTAssertTrue(exp.status == .draft)
        XCTAssertEqual(exp.durationDays, 7)
    }
    
    // MARK: - Initialization Validation Failures
    
    func test_initWithEmptyName_throws() throws {
        let variant = try Variant(
            experimentID: "exp1",
            name: "A",
            allocationPercentage: 100.0,
            configuration: .init()
        )
        
        XCTAssertThrowsError(
            try Experiment(
                name: "   ", // whitespace only
                description: "Test",
                hypothesis: "Test",
                variants: [variant],
                successMetrics: [.correctAnswerRate],
                startDate: Date()
            )
        ) { error in
            guard case let .invalidExperiment(violations) = error as? DomainError else {
                XCTFail("Expected invalidExperiment error")
                return
            }
            XCTAssertTrue(violations.contains { $0.contains("name") })
        }
    }
    
    func test_initWithNoVariants_throws() throws {
        XCTAssertThrowsError(
            try Experiment(
                name: "Empty Experiment",
                description: "Test",
                hypothesis: "Test",
                variants: [], // ❌
                successMetrics: [.correctAnswerRate],
                startDate: Date()
            )
        ) { error in
            guard case let .invalidExperiment(violations) = error as? DomainError else {
                XCTFail("Expected invalidExperiment error")
                return
            }
            XCTAssertTrue(violations.contains { $0.contains("variant") })
        }
    }
    
    func test_initWithNoSuccessMetrics_throws() throws {
        let variant = try Variant(
            experimentID: "exp1",
            name: "A",
            allocationPercentage: 100.0,
            configuration: .init()
        )
        
        XCTAssertThrowsError(
            try Experiment(
                name: "Test",
                description: "Test",
                hypothesis: "Test",
                variants: [variant],
                successMetrics: [], // ❌
                startDate: Date()
            )
        ) { error in
            guard case let .invalidExperiment(violations) = error as? DomainError else {
                XCTFail("Expected invalidExperiment error")
                return
            }
            XCTAssertTrue(violations.contains { $0.contains("metric") })
        }
    }
    
    func test_initWithInvalidDateRange_throws() throws {
        let variant = try Variant(
            experimentID: "exp1",
            name: "A",
            allocationPercentage: 100.0,
            configuration: .init()
        )
        
        let start = Date()
        let end = Date(timeIntervalSinceNow: -3600) // past
        
        XCTAssertThrowsError(
            try Experiment(
                name: "Test",
                description: "Test",
                hypothesis: "Test",
                variants: [variant],
                successMetrics: [.correctAnswerRate],
                startDate: start,
                endDate: end
            )
        ) { error in
            guard case .dateRangeInvalid = error as? DomainError else {
                XCTFail("Expected dateRangeInvalid error")
                return
            }
        }
    }
    
    func test_initWithAllocationNotSumTo100_throws() throws {
        let var1 = try Variant(
            experimentID: "exp1",
            name: "A",
            allocationPercentage: 50.0,
            configuration: .init()
        )
        let var2 = try Variant(
            experimentID: "exp1",
            name: "B",
            allocationPercentage: 40.0, // Should be 50.0
            configuration: .init()
        )
        
        XCTAssertThrowsError(
            try Experiment(
                name: "Test",
                description: "Test",
                hypothesis: "Test",
                variants: [var1, var2],
                successMetrics: [.correctAnswerRate],
                startDate: Date()
            )
        ) { error in
            guard case let .allocationMismatch(expected, actual) = error as? DomainError else {
                XCTFail("Expected allocationMismatch error")
                return
            }
            XCTAssertEqual(expected, 100.0, accuracy: 0.01)
            XCTAssertEqual(actual, 90.0, accuracy: 0.01)
        }
    }
    
    // MARK: - Allocation Edge Cases
    
    func test_allocationSum100_0_withTolerance_succeeds() throws {
        // Test floating point tolerance: 99.999% should be accepted
        let var1 = try Variant(
            experimentID: "exp1",
            name: "A",
            allocationPercentage: 33.333,
            configuration: .init()
        )
        let var2 = try Variant(
            experimentID: "exp1",
            name: "B",
            allocationPercentage: 33.333,
            configuration: .init()
        )
        let var3 = try Variant(
            experimentID: "exp1",
            name: "C",
            allocationPercentage: 33.334,
            configuration: .init()
        )
        
        // Should not throw (within 0.01% tolerance)
        let exp = try Experiment(
            name: "Test",
            description: "Test",
            hypothesis: "Test",
            variants: [var1, var2, var3],
            successMetrics: [.correctAnswerRate],
            startDate: Date()
        )
        
        XCTAssertEqual(exp.variants.count, 3)
    }
    
    // MARK: - Status Transitions
    
    func test_statusTransitions() throws {
        var exp = try Experiment(
            name: "Test",
            description: "Test",
            hypothesis: "Test",
            variants: [
                try Variant(
                    experimentID: "exp1",
                    name: "A",
                    allocationPercentage: 100.0,
                    configuration: .init()
                )
            ],
            successMetrics: [.correctAnswerRate],
            startDate: Date()
        )
        
        XCTAssertEqual(exp.status, .draft)
        
        exp.status = .active
        XCTAssertTrue(exp.isActive) // isActive also checks date
        
        exp.status = .paused
        XCTAssertFalse(exp.isActive)
        
        exp.status = .completed
        XCTAssertFalse(exp.isActive)
    }
    
    // MARK: - Computed Properties
    
    func test_durationDaysCalculation() throws {
        let start = Date()
        let end = Date(timeIntervalSinceNow: 86400 * 14) // 14 days
        
        let exp = try Experiment(
            name: "Test",
            description: "Test",
            hypothesis: "Test",
            variants: [
                try Variant(
                    experimentID: "exp1",
                    name: "A",
                    allocationPercentage: 100.0,
                    configuration: .init()
                )
            ],
            successMetrics: [.correctAnswerRate],
            startDate: start,
            endDate: end
        )
        
        XCTAssertEqual(exp.durationDays, 14)
    }
    
    func test_durationDaysNilWhenNoEndDate() throws {
        let exp = try Experiment(
            name: "Test",
            description: "Test",
            hypothesis: "Test",
            variants: [
                try Variant(
                    experimentID: "exp1",
                    name: "A",
                    allocationPercentage: 100.0,
                    configuration: .init()
                )
            ],
            successMetrics: [.correctAnswerRate],
            startDate: Date(),
            endDate: nil
        )
        
        XCTAssertNil(exp.durationDays)
    }
    
    // MARK: - Codable Round-Trip
    
    func test_codableRoundTrip() throws {
        let original = try Experiment(
            name: "Codable Test",
            description: "Testing serialization",
            hypothesis: "Hypothesis",
            variants: [
                try Variant(
                    experimentID: "exp1",
                    name: "Control",
                    allocationPercentage: 50.0,
                    configuration: .init()
                ),
                try Variant(
                    experimentID: "exp1",
                    name: "Treatment",
                    allocationPercentage: 50.0,
                    configuration: .init(answerLayout: .horizontal)
                )
            ],
            successMetrics: [.correctAnswerRate, .averageTimeToAnswer],
            startDate: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(Experiment.self, from: data)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.variants.count, original.variants.count)
        XCTAssertEqual(decoded.successMetrics.count, original.successMetrics.count)
    }
    
    func test_decodingInvalidExperimentThrows() throws {
        let invalidJSON = """
        {
            "id": "exp1",
            "name": "Test",
            "description": "Test",
            "hypothesis": "Test",
            "variants": [],
            "successMetrics": [],
            "startDate": "2026-04-03T00:00:00Z",
            "endDate": null,
            "targetPopulation": {"rule": "allUsers"},
            "status": "draft",
            "createdAt": "2026-04-03T00:00:00Z",
            "updatedAt": "2026-04-03T00:00:00Z"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        XCTAssertThrowsError(
            try decoder.decode(Experiment.self, from: invalidJSON)
        ) { error in
            guard let domainError = error as? DomainError,
                  case .invalidExperiment = domainError else {
                XCTFail("Expected invalidExperiment error on decode")
                return
            }
        }
    }
}