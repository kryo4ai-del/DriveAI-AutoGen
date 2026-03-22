class ExerciseModelTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func testExerciseInitialization() {
        let exercise = Exercise(
            id: UUID(),
            name: "Road Signs Quiz",
            description: "Learn common road signs",
            category: .roadSigns,
            difficulty: .intermediate,
            estimatedDuration: 10,
            questionCount: 20,
            icon: "triangle.fill",
            color: "yellow"
        )
        
        XCTAssertEqual(exercise.name, "Road Signs Quiz")
        XCTAssertEqual(exercise.category, .roadSigns)
        XCTAssertEqual(exercise.estimatedDuration, 10)
        XCTAssertEqual(exercise.questionCount, 20)
    }
    
    func testExerciseIdentifiable() {
        let id = UUID()
        let exercise = Exercise(
            id: id,
            name: "Test",
            description: "Test",
            category: .trafficRules,
            difficulty: .beginner,
            estimatedDuration: 5,
            questionCount: 10,
            icon: "circle",
            color: "blue"
        )
        
        XCTAssertEqual(exercise.id, id)
    }
    
    func testExerciseHashable() {
        let id = UUID()
        let exercise1 = Exercise(
            id: id,
            name: "Test",
            description: "Test",
            category: .roadSigns,
            difficulty: .beginner,
            estimatedDuration: 5,
            questionCount: 10,
            icon: "circle",
            color: "blue"
        )
        
        let exercise2 = Exercise(
            id: id,
            name: "Different Name", // Different name, same ID
            description: "Test",
            category: .trafficRules,
            difficulty: .advanced,
            estimatedDuration: 15,
            questionCount: 30,
            icon: "square",
            color: "red"
        )
        
        // Hash should be based on ID only
        XCTAssertEqual(exercise1.hashValue, exercise2.hashValue)
    }
    
    // MARK: - Codable
    
    func testExerciseJSONDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "Road Signs Quiz",
            "description": "Learn common road signs",
            "category": "roadSigns",
            "difficulty": "intermediate",
            "estimated_duration": 10,
            "question_count": 20,
            "icon": "triangle.fill",
            "color": "yellow"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let exercise = try decoder.decode(Exercise.self, from: json)
        
        XCTAssertEqual(exercise.name, "Road Signs Quiz")
        XCTAssertEqual(exercise.category, .roadSigns)
        XCTAssertEqual(exercise.estimatedDuration, 10)
    }
    
    func testExerciseJSONDecodingInvalidCategory() {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "Test",
            "description": "Test",
            "category": "invalidCategory",
            "difficulty": "beginner",
            "estimated_duration": 5,
            "question_count": 10,
            "icon": "circle",
            "color": "blue"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(Exercise.self, from: json))
    }
    
    func testExerciseJSONDecodingMissingFields() {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "Test"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(Exercise.self, from: json))
    }
    
    // MARK: - Edge Cases
    
    func testExerciseWithZeroDuration() {
        let exercise = Exercise(
            id: UUID(),
            name: "Test",
            description: "Test",
            category: .roadSigns,
            difficulty: .beginner,
            estimatedDuration: 0,
            questionCount: 0,
            icon: "circle",
            color: "blue"
        )
        
        XCTAssertEqual(exercise.estimatedDuration, 0)
        XCTAssertEqual(exercise.questionCount, 0)
    }
    
    func testExerciseWithLongDescription() {
        let longDescription = String(repeating: "A", count: 1000)
        let exercise = Exercise(
            id: UUID(),
            name: "Test",
            description: longDescription,
            category: .roadSigns,
            difficulty: .beginner,
            estimatedDuration: 5,
            questionCount: 10,
            icon: "circle",
            color: "blue"
        )
        
        XCTAssertEqual(exercise.description.count, 1000)
    }
}