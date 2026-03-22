import Foundation

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var seed: UInt64

    init(seed: UInt64 = 42) {
        self.seed = seed
    }

    mutating func next() -> UInt64 {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return seed
    }
}
