// Tests/Services/SignValidationServiceTests.swift

import XCTest
@testable import DriveAI

@MainActor
final class SignValidationServiceTests: XCTestCase {
    var sut: SignValidationService!
    var mockCatalog: MockQuestionCatalog!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockCatalog = MockQuestionCatalog()
        mockLogger = MockLogger()
        sut = SignValidationService(questionCatalog: mockCatalog, logger: mockLogger)
    }
    
    override func tearDown() {
        sut = nil
        mockCatalog = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Valid Sign Recognition
    
    func testValidateGiveWaySign_WithHighConfidence() async {
        // Arrange
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .rightOfWay, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Yield sign",
            confidence: 0.95,
            imageData: UIImage(systemName: "circle.fill")?.pngData() ?? Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .valid(let category, let confidence) = result else {
            XCTFail("Expected .valid, got \(result)")
            return
        }
        XCTAssertEqual(category, .rightOfWay)
        XCTAssertEqual(confidence, 0.95)
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("validated") })
    }
    
    func testValidateSpeedLimitSign_MapsToSpeedCategory() async {
        // Arrange
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .speed, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .speedLimit50,
            description: "50 km/h sign",
            confidence: 0.88,
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .valid(let category, _) = result else {
            XCTFail("Expected valid result")
            return
        }
        XCTAssertEqual(category, .speed)
    }
    
    func testValidateStopSign_HighConfidencePath() async {
        // Arrange
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .rightOfWay, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .stop,
            description: "Stop sign",
            confidence: 0.99,
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .valid(let category, let confidence) = result else {
            XCTFail("Expected valid")
            return
        }
        XCTAssertEqual(confidence, 0.99)
        XCTAssertEqual(category, .rightOfWay)
    }
}

// MARK: - Edge Cases: Confidence Threshold

extension SignValidationServiceTests {
    func testValidateSign_BelowMinimumConfidence() async {
        // Arrange
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Low confidence yield",
            confidence: 0.74,  // Below 0.75 threshold
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .lowConfidence(let actual, let required) = result else {
            XCTFail("Expected .lowConfidence, got \(result)")
            return
        }
        XCTAssertEqual(actual, 0.74)
        XCTAssertEqual(required, 0.75)
        XCTAssertEqual(result.userMessage, "📸 Nur 74% sicher (mindestens 75% nötig)")
    }
    
    func testValidateSign_ExactlyAtMinimumConfidence() async {
        // Arrange
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .rightOfWay, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Edge case confidence",
            confidence: 0.75,  // Exactly at threshold
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .valid = result else {
            XCTFail("Expected valid at exact threshold")
            return
        }
    }
    
    func testValidateSign_VeryHighConfidence() async {
        // Arrange
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .rightOfWay, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Perfect recognition",
            confidence: 1.0,
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .valid(_, let confidence) = result else {
            XCTFail("Expected valid")
            return
        }
        XCTAssertEqual(confidence, 1.0)
    }
    
    func testValidateSign_ConfidenceNormalization() async {
        // Test that confidence > 1.0 is clamped to 1.0
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .rightOfWay, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Over-confident",
            confidence: 1.5,  // Invalid input
            imageData: Data()
        )
        
        let result = await sut.validate(sign)
        
        guard case .valid(_, let confidence) = result else {
            XCTFail("Expected valid (with normalization)")
            return
        }
        XCTAssertEqual(confidence, 1.0)
    }
}

// MARK: - Edge Cases: Ambiguous Signs

extension SignValidationServiceTests {
    func testValidateSign_MultipleValidCategories() async {
        // Arrange: Speed limits map to both .speed and .trafficRules
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .speed, correctAnswerIndex: 0),
            ExamQuestion(id: UUID(), text: "...", category: .trafficRules, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .speedLimit50,
            description: "Speed limit sign",
            confidence: 0.85,
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .ambiguous(let candidates) = result else {
            XCTFail("Expected .ambiguous, got \(result)")
            return
        }
        XCTAssertEqual(candidates.count, 2)
        XCTAssert(candidates.contains(.speed))
        XCTAssert(candidates.contains(.trafficRules))
    }
    
    func testValidateSign_AmbiguousMessage() async {
        // Arrange
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .prohibitedActions, correctAnswerIndex: 0),
            ExamQuestion(id: UUID(), text: "...", category: .trafficRules, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .oneway,
            description: "One-way street",
            confidence: 0.80,
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        XCTAssertTrue(result.userMessage.contains("🤔"))
        XCTAssertTrue(result.userMessage.contains("Könnte sein"))
    }
}

// MARK: - Invalid / Not in Catalog

extension SignValidationServiceTests {
    func testValidateSign_NotInCatalog_Unknown() async {
        // Arrange
        mockCatalog.mockQuestions = []  // Empty catalog
        let sign = RecognizedSign(
            type: .unknown,
            description: "Unknown sign type",
            confidence: 0.85,
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .notInCatalog(let description) = result else {
            XCTFail("Expected .notInCatalog")
            return
        }
        XCTAssertEqual(description, "Unknown sign type")
        XCTAssertTrue(result.userMessage.contains("⚠️"))
    }
    
    func testValidateSign_CandidatesExistButNoCatalogQuestions() async {
        // Arrange: GiveWay maps to .rightOfWay, but no questions for that category
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .speed, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Yield sign",
            confidence: 0.90,
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .notInCatalog = result else {
            XCTFail("Expected .notInCatalog when category has no questions")
            return
        }
    }
    
    func testValidateSign_EmptyCatalog() async {
        // Arrange
        mockCatalog.mockQuestions = []
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Any sign",
            confidence: 0.95,
            imageData: Data()
        )
        
        // Act
        let result = await sut.validate(sign)
        
        // Assert
        guard case .notInCatalog = result else {
            XCTFail("Expected .notInCatalog")
            return
        }
    }
}

// MARK: - Recovery Actions

extension SignValidationServiceTests {
    func testValidationResult_RecoveryActionForValidSign() {
        // Arrange
        let result: ValidationResult = .valid(category: .rightOfWay, confidence: 0.95)
        
        // Act & Assert
        XCTAssertEqual(result.recoveryAction, .confirm)
    }
    
    func testValidationResult_RecoveryActionForAmbiguous() {
        // Arrange
        let result: ValidationResult = .ambiguous(candidates: [.speed, .trafficRules])
        
        // Act & Assert
        XCTAssertEqual(result.recoveryAction, .selectCategory)
    }
    
    func testValidationResult_RecoveryActionForLowConfidence() {
        // Arrange
        let result: ValidationResult = .lowConfidence(actual: 0.5, required: 0.75)
        
        // Act & Assert
        XCTAssertEqual(result.recoveryAction, .retakePhoto)
    }
    
    func testValidationResult_RecoveryActionForNotInCatalog() {
        // Arrange
        let result: ValidationResult = .notInCatalog(description: "Random shape")
        
        // Act & Assert
        XCTAssertEqual(result.recoveryAction, .dismiss)
    }
}

// MARK: - GetCategoryForSign Helper

extension SignValidationServiceTests {
    func testGetCategoryForSign_ReturnsCategory() async {
        // Arrange
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .rightOfWay, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Yield",
            confidence: 0.95,
            imageData: Data()
        )
        
        // Act
        let category = await sut.getCategoryForSign(sign)
        
        // Assert
        XCTAssertEqual(category, .rightOfWay)
    }
    
    func testGetCategoryForSign_ReturnsNilForInvalid() async {
        // Arrange
        mockCatalog.mockQuestions = []
        let sign = RecognizedSign(
            type: .unknown,
            description: "Unknown",
            confidence: 0.85,
            imageData: Data()
        )
        
        // Act
        let category = await sut.getCategoryForSign(sign)
        
        // Assert
        XCTAssertNil(category)
    }
}

// MARK: - Logging Verification

extension SignValidationServiceTests {
    func testValidation_LogsSuccessfulValidation() async {
        // Arrange
        mockCatalog.mockQuestions = [
            ExamQuestion(id: UUID(), text: "...", category: .rightOfWay, correctAnswerIndex: 0)
        ]
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Yield",
            confidence: 0.95,
            imageData: Data()
        )
        
        // Act
        _ = await sut.validate(sign)
        
        // Assert
        XCTAssertTrue(mockLogger.infoMessages.contains { $0.contains("validated") })
    }
    
    func testValidation_LogsLowConfidence() async {
        // Arrange
        let sign = RecognizedSign(
            type: .giveWay,
            description: "Low conf",
            confidence: 0.50,
            imageData: Data()
        )
        
        // Act
        _ = await sut.validate(sign)
        
        // Assert
        XCTAssertTrue(mockLogger.warningMessages.contains { $0.contains("Low confidence") })
    }
}