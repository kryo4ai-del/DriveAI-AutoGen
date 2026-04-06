extension QuestionModelTests {
    
    func testQuestion_WithVeryLongText() throws {
        // Arrange: 5000+ character question text
        let longText = String(repeating: "A", count: 5000)
        let json = """
        {
            "id": 1,
            "categoryId": 1,
            "text": "\(longText)",
            "answers": ["A", "B", "C", "D"],
            "correctAnswerIndex": 0,
            "explanation": "Test",
            "imageUrl": null,
            "difficulty": "hard"
        }
        """
        
        // Act & Assert: Should not crash
        let data = json.data(using: .utf8)!
        let question = try JSONDecoder().decode(Question.self, from: data)
        XCTAssertEqual(question.text.count, 5000)
    }
    
    func testQuestion_WithSpecialCharacters() throws {
        // Arrange: Unicode, emojis, special chars
        let json = """
        {
            "id": 2,
            "categoryId": 1,
            "text": "Straße Ä Ö Ü 中文 🚗",
            "answers": ["✓", "❌", "⚠️", "🛑"],
            "correctAnswerIndex": 0,
            "explanation": "Müller's answer",
            "imageUrl": null,
            "difficulty": "easy"
        }
        """
        
        // Act
        let data = json.data(using: .utf8)!
        let question = try JSONDecoder().decode(Question.self, from: data)
        
        // Assert
        XCTAssert(question.text.contains("Ä"))
        XCTAssert(question.text.contains("🚗"))
    }
    
    func testQuestion_MissingOptionalField() throws {
        // Arrange: No imageUrl (optional)
        let json = """
        {
            "id": 1,
            "categoryId": 1,
            "text": "Question?",
            "answers": ["A", "B", "C", "D"],
            "correctAnswerIndex": 0,
            "explanation": "Explanation",
            "difficulty": "easy"
        }
        """
        
        // Act & Assert
        let data = json.data(using: .utf8)!
        let question = try JSONDecoder().decode(Question.self, from: data)
        XCTAssertNil(question.imageUrl)
    }
    
    func testQuestion_InvalidCorrectAnswerIndex() throws {
        // Arrange: correctAnswerIndex exceeds answer count
        let json = """
        {
            "id": 1,
            "categoryId": 1,
            "text": "Question?",
            "answers": ["A", "B"],
            "correctAnswerIndex": 5,
            "explanation": "Explanation",
            "imageUrl": null,
            "difficulty": "easy"
        }
        """
        
        // Act: Should decode but validation happens elsewhere
        let data = json.data(using: .utf8)!
        let question = try JSONDecoder().decode(Question.self, from: data)
        
        // Assert: Flag as invalid in ViewModel/Service
        XCTAssertGreaterThanOrEqual(question.correctAnswerIndex, question.answers.count)
    }
    
    func testQuestion_MalformedJSON() throws {
        // Arrange: Invalid JSON
        let json = """
        {
            "id": "not_an_int",
            "categoryId": 1,
            ...
        }
        """
        
        // Act & Assert: Should throw DecodingError
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Question.self, from: data)) { error in
            XCTAssert(error is DecodingError)
        }
    }
}