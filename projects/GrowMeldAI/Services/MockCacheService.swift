// BEFORE: No expiration
class MockCacheService {
    var cachedProducts: [MockProduct] = []
    
    func getCached() -> [MockProduct]? {
        cachedProducts.isEmpty ? nil : cachedProducts
    }
}

// AFTER: TTL-based expiration

// Test:
func test_getCached_returnsNil_whenExpired() async throws {
    let expiredDate = Date().addingTimeInterval(-3601)
    userDefaults.set(expiredDate, forKey: "cached_products_expiry")
    
    let result = await sut.getCached()
    XCTAssertNil(result)
}