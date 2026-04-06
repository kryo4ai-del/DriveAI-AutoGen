// Services/Crashlytics/CircularBuffer.swift

import Foundation

/// Thread-safe, fixed-capacity circular buffer for breadcrumbs
final class CircularBuffer<Element>: Sendable {
    private let capacity: Int
    private var buffer: [Element?]
    private var writeIndex: Int = 0
    private let lock = NSLock()
    
    init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be > 0")
        self.capacity = capacity
        self.buffer = Array(repeating: nil, count: capacity)
    }
    
    /// Append element; oldest auto-discarded when full
    func append(_ element: Element) {
        lock.withLock {
            buffer[writeIndex] = element
            writeIndex = (writeIndex + 1) % capacity
        }
    }
    
    /// Get all non-nil elements in FIFO order
    func allElements() -> [Element] {
        lock.withLock {
            buffer.compactMap { $0 }
        }
    }
    
    /// Clear buffer
    func clear() {
        lock.withLock {
            buffer = Array(repeating: nil, count: capacity)
            writeIndex = 0
        }
    }
    
    /// Current count
    var count: Int {
        lock.withLock {
            buffer.compactMap { $0 }.count
        }
    }
}