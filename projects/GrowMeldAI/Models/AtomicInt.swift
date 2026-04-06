import Foundation

class AtomicInt {
    private var value: Int
    private let lock = NSLock()
    init(_ value: Int = 0) { self.value = value }
    func get() -> Int { lock.lock(); defer { lock.unlock() }; return value }
    func increment() { lock.lock(); value += 1; lock.unlock() }
}
