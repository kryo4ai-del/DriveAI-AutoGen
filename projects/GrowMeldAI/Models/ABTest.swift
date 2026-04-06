import Foundation

// MARK: - Core Data Models

struct ABTest: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let active: Bool
    let variants: [TestVariant]
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String,
        name: String,
        description: String? = nil,
        active: Bool = true,
        variants: [TestVariant],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.active = active
        self.variants = variants
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct TestVariant: Codable, Identifiable {
    let id: String
    let name: String
    let percentile: Int  // 0-100; allocation %
    let description: String?
    
    init(id: String, name: String, percentile: Int, description: String? = nil) {
        self.id = id
        self.name = name
        self.percentile = percentile
        self.description = description
    }
}

struct TestResult: Codable, Identifiable {
    let id: String
    let testID: String
    let variantID: String
    let userIDHash: String
    let outcome: String  // "pass", "fail", or custom metric
    let metadataJSON: String?  // Optional rich data
    let timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        testID: String,
        variantID: String,
        userIDHash: String,
        outcome: String,
        metadataJSON: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.testID = testID
        self.variantID = variantID
        self.userIDHash = userIDHash
        self.outcome = outcome
        self.metadataJSON = metadataJSON
        self.timestamp = timestamp
    }
}

struct ABTestAssignment: Codable {
    let testID: String
    let variantID: String
    let assignedAt: Date
    
    init(testID: String, variantID: String, assignedAt: Date = Date()) {
        self.testID = testID
        self.variantID = variantID
        self.assignedAt = assignedAt
    }
}