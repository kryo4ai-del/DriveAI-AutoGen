import Foundation
import Combine

@MainActor
final class ABTestService: ObservableObject {
    @Published private(set) var config: ABTestConfig?
    @Published private(set) var isReady = false
    @Published private(set) var loadError: String?

    private let userID: String
    private var variantCache: [String: String] = [:]
    private let cacheLock = NSLock()

    init(userID: String) {
        self.userID = userID

        Task {
            await loadConfigAsync()
        }
    }

    // MARK: - Private Loading

    private func loadConfigAsync() async {
        defer {
            self.isReady = true
        }

        guard let configURL = Bundle.main.url(forResource: "ab_test_config", withExtension: "json") else {
            self.loadError = "ab_test_config.json not found in bundle"
            return
        }

        do {
            let data = try Data(contentsOf: configURL)
            let decoded = try JSONDecoder().decode(ABTestConfig.self, from: data)
            self.config = decoded
            self.loadError = nil
        } catch let error as DecodingError {
            self.loadError = "Config decode error: \(error)"
        } catch {
            self.loadError = "Config load error: \(error.localizedDescription)"
        }
    }

    // MARK: - Public API

    /// Get variant for a given test ID. Returns nil if not ready, config missing, or user not in sample.
    func getVariant(for testID: String) -> String? {
        guard isReady else {
            assertionFailure("getVariant() called before config loaded. Check isReady first.")
            return nil
        }

        guard let config = config else {
            assertionFailure("getVariant() called but config failed to load: \(loadError ?? "unknown")")
            return nil
        }

        cacheLock.lock()
        defer { cacheLock.unlock() }

        if let cached = variantCache[testID] {
            return cached
        }

        guard let test = config.tests.first(where: { $0.id == testID }),
              test.enabled else {
            return nil
        }

        let now = Date()
        if let start = test.startDate, now < start { return nil }
        if let end = test.endDate, now > end { return nil }

        let userHash = hashUserForTest(userID: userID, testID: testID)
        if userHash >= test.sampleSizePercent {
            return nil
        }

        let variant = assignVariant(from: test.variants, userID: userID, testID: testID)
        variantCache[testID] = variant.id

        return variant.id
    }

    // MARK: - Hashing Helpers

    private func hashUserForTest(userID: String, testID: String) -> Double {
        let combined = "\(userID):\(testID)"
        var hash: UInt64 = 5381
        for char in combined.unicodeScalars {
            hash = hash &* 31 &+ UInt64(char.value)
        }
        // Map to 0..<100
        return Double(hash % 100)
    }

    private func assignVariant(from variants: [ABTestVariant], userID: String, testID: String) -> ABTestVariant {
        let combined = "\(userID):\(testID):variant"
        var hash: UInt64 = 5381
        for char in combined.unicodeScalars {
            hash = hash &* 31 &+ UInt64(char.value)
        }

        // Weighted selection based on variant weights
        let totalWeight = variants.reduce(0.0) { $0 + $1.weight }
        guard totalWeight > 0 else { return variants[0] }

        let normalized = Double(hash % 10000) / 10000.0 * totalWeight
        var cumulative = 0.0
        for variant in variants {
            cumulative += variant.weight
            if normalized < cumulative {
                return variant
            }
        }
        return variants[variants.count - 1]
    }
}

// MARK: - Supporting Models

struct ABTestConfig: Codable {
    let tests: [ABTest]
}

struct ABTest: Codable {
    let id: String
    let enabled: Bool
    let sampleSizePercent: Double
    let variants: [ABTestVariant]
    let startDate: Date?
    let endDate: Date?

    enum CodingKeys: String, CodingKey {
        case id, enabled, sampleSizePercent, variants, startDate, endDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        enabled = try container.decode(Bool.self, forKey: .enabled)
        sampleSizePercent = try container.decode(Double.self, forKey: .sampleSizePercent)
        variants = try container.decode([ABTestVariant].self, forKey: .variants)

        let formatter = ISO8601DateFormatter()
        if let startStr = try container.decodeIfPresent(String.self, forKey: .startDate) {
            startDate = formatter.date(from: startStr)
        } else {
            startDate = nil
        }
        if let endStr = try container.decodeIfPresent(String.self, forKey: .endDate) {
            endDate = formatter.date(from: endStr)
        } else {
            endDate = nil
        }
    }
}

struct ABTestVariant: Codable {
    let id: String
    let weight: Double
    let metadata: [String: String]?
}