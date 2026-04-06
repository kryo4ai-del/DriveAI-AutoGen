class FreemiumStateCodeableTests: XCTestCase {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func test_encodeDecodeRoundtrip_unlimited() throws {
        let original: FreemiumState = .unlimited(premiumUntil: Date(timeIntervalSince1970: 0))
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(FreemiumState.self, from: data)
        
        XCTAssertEqual(original, decoded)
    }
    
    func test_encodeDecodeRoundtrip_freeTierActive() throws {
        let original: FreemiumState = .freeTierActive(questionsRemaining: 3)
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(FreemiumState.self, from: data)
        
        XCTAssertEqual(original, decoded)
    }
    
    func test_encodeDecodeRoundtrip_trialActive() throws {
        let original: FreemiumState = .trialActive(daysRemaining: 7, questionsUsed: 12)
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(FreemiumState.self, from: data)
        
        XCTAssertEqual(original, decoded)
    }
    
    func test_decodeUnknownType_fallsBackToFreeTier() throws {
        let json = """
        {
            "_v": 1,
            "type": "future_unknown_state"
        }
        """.data(using: .utf8)!
        
        let decoded = try decoder.decode(FreemiumState.self, from: json)
        
        if case .freeTierActive(let remaining) = decoded {
            XCTAssertEqual(remaining, 5)
        } else {
            XCTFail("Should fallback to free tier")
        }
    }
    
    func test_decodeLegacyData_withoutSchemaVersion() throws {
        // Simulate v0 data without _v field
        let legacyJSON = """
        {
            "type": "free_tier_active",
            "questionsRemaining": 4
        }
        """.data(using: .utf8)!
        
        let decoded = try decoder.decode(FreemiumState.self, from: legacyJSON)
        
        if case .freeTierActive(let remaining) = decoded {
            XCTAssertEqual(remaining, 4, "Should decode legacy data without schema version")
        }
    }
    
    func test_decodeFutureSchema_throwsError() throws {
        let futureJSON = """
        {
            "_v": 999,
            "type": "free_tier_active",
            "questionsRemaining": 2
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(
            try decoder.decode(FreemiumState.self, from: futureJSON)
        ) { error in
            if let quotaError = error as? QuotaError, case .invalidState = quotaError {
                // Expected
            } else {
                XCTFail("Should throw QuotaError.invalidState for unsupported schema")
            }
        }
    }
    
    func test_encodeIncludesSchemaVersion() throws {
        let state: FreemiumState = .freeTierActive(questionsRemaining: 5)
        let data = try encoder.encode(state)
        
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["_v"] as? Int, 1, "Encoded state should include schema version")
    }
}