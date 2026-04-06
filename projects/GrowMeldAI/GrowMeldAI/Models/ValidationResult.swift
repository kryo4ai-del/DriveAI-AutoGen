// ✅ CORRECTED
private func validateJSON(_ data: Data) -> ValidationResult {
    do {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return .failure("Invalid JSON structure: expected array of objects")
        }
        
        guard !json.isEmpty else {
            return .failure("Questions array is empty")
        }
        
        let requiredKeys = ["id", "question", "answers"]
        for (index, dict) in json.enumerated() {
            let missingKeys = requiredKeys.filter { dict[$0] == nil }
            if !missingKeys.isEmpty {
                return .failure("Question at index \(index) missing keys: \(missingKeys.joined(separator: ", "))")
            }
        }
        
        return .success
    } catch {
        return .failure("JSON parsing error: \(error.localizedDescription)")
    }
}

enum ValidationResult {
    case success
    case failure(String)
    
    var isValid: Bool {
        if case .success = self { return true }
        return false
    }
}

// Usage:
private func reloadQuestionCache() async throws {
    let data = try Data(contentsOf: questionsURL)
    
    let validation = validateJSON(data)
    guard case .success = validation else {
        if case .failure(let reason) = validation {
            os_log("Database validation failed: %{public}@", log: .data, type: .error, reason)
        }
        throw DataError.corruptedDatabase
    }
    
    // ... proceed
}