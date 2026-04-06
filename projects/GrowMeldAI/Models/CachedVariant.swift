import Foundation

// TestVariant is defined in Models/ABTest.swift

private struct CachedVariant {
    let variantID: String
    let cachedAt: Date
}

private var assignmentCache: [String: CachedVariant] = [:]
private let cacheTTL: TimeInterval = 3600  // 1 hour

private func getVariant(testID: String, variantID: String) -> TestVariant? {
    // Attempt to retrieve a cached variant from persisted assignments
    let key = "ab_test_assignment_\(testID)"
    guard let data = UserDefaults.standard.data(forKey: key),
          let assignment = try? JSONDecoder().decode(ABTestAssignment.self, from: data),
          assignment.variantID == variantID else {
        return nil
    }
    // Return a minimal TestVariant based on stored assignment
    return TestVariant(id: variantID, name: variantID, percentile: 0)
}

private func determineVariant(testID: String, userIDHash: Int, variants: [TestVariant]) -> TestVariant {
    guard !variants.isEmpty else {
        return TestVariant(id: "control", name: "Control", percentile: 100)
    }

    let bucket = userIDHash % ABTestConstants.hashModulo
    var cumulative = 0

    for variant in variants {
        cumulative += variant.percentile
        if bucket < cumulative {
            return variant
        }
    }

    return variants.last ?? TestVariant(id: "control", name: "Control", percentile: 100)
}

// MARK: - Repository & Segmentation Stubs

private struct UserSegmentation {
    func getUserIDHash() -> Int {
        let userID = UserDefaults.standard.string(forKey: "user_id") ?? UUID().uuidString
        return abs(userID.hashValue) % ABTestConstants.hashModulo
    }
}

private struct ABTestRepository {
    func getTest(id: String) -> ABTest? {
        let key = "ab_test_\(id)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let test = try? JSONDecoder().decode(ABTest.self, from: data) else {
            return nil
        }
        return test
    }
}

private let repository = ABTestRepository()
private let userSegmentation = UserSegmentation()

func assignVariant(testID: String) -> TestVariant? {
    // 1. Check cache (with TTL)
    if let cached = assignmentCache[testID],
       Date().timeIntervalSince(cached.cachedAt) < cacheTTL,
       let variant = getVariant(testID: testID, variantID: cached.variantID) {
        return variant
    }

    // 2. Fetch fresh from DB
    guard let test = repository.getTest(id: testID), test.active else {
        assignmentCache.removeValue(forKey: testID)
        return nil
    }

    let userHash = userSegmentation.getUserIDHash()
    let assignedVariant = determineVariant(
        testID: testID,
        userIDHash: userHash,
        variants: test.variants
    )

    // 3. Update cache with timestamp
    assignmentCache[testID] = CachedVariant(
        variantID: assignedVariant.id,
        cachedAt: Date()
    )

    return assignedVariant
}