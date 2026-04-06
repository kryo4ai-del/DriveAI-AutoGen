func test_loadProducts_concurrentCalls_singleNetworkRequest() async {
  let counter = AtomicInt(0) // Use non-actor struct for simplicity
  
  mockStoreKit.onLoadProducts = {
    counter.atomicallyIncrement() // Thread-safe operation
  }
  
  // ... rest of test
  XCTAssertEqual(counter.value, 1)
}

struct AtomicInt {
  private let lock = NSLock()
  private var _value: Int = 0
  
  var value: Int {
    lock.withLock { _value }
  }
  
  mutating func atomicallyIncrement() {
    lock.withLock { _value += 1 }
  }
}