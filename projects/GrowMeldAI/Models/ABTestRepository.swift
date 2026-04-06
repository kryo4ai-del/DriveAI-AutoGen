// ABTestRepository.swift
import Foundation

class ABTestRepository {
    private let database: DriveAIDatabase

    init(database: DriveAIDatabase) {
        self.database = database
    }

    // MARK: - Test Management
    func getActiveTests() -> [ABTest] {
        // SELECT * FROM ab_tests WHERE active = 1
        return database.fetchActiveTests()
    }

    func saveTest(_ test: ABTest) throws {
        // INSERT OR REPLACE INTO ab_tests
        try database.saveTest(test)
    }

    // MARK: - Results Logging
    func logResult(_ result: TestResult) throws {
        // INSERT INTO ab_results (test_id, variant_id, user_hash, outcome, timestamp)
        try database.saveResult(result)
    }

    func getResults(testID: String) -> [TestResult] {
        // SELECT * FROM ab_results WHERE test_id = ?
        return database.fetchResults(testID: testID)
    }

    // MARK: - Analytics
    func getConversionRate(testID: String, variantID: String) -> Double {
        let successes = countResults(testID: testID, variantID: variantID, outcome: "pass")
        let total = countResults(testID: testID, variantID: variantID)
        guard total > 0 else { return 0.0 }
        return Double(successes) / Double(total)
    }

    // MARK: - Private Helpers

    private func countResults(testID: String, variantID: String, outcome: String? = nil) -> Int {
        let results = database.fetchResults(testID: testID).filter { $0.variantID == variantID }
        if let outcome = outcome {
            return results.filter { $0.outcome == outcome }.count
        }
        return results.count
    }
}

// MARK: - DriveAIDatabase

/// In-memory + file-backed persistence layer replacing any third-party database dependency.
class DriveAIDatabase {
    private let testsFileURL: URL
    private let resultsFileURL: URL

    private var testsCache: [String: ABTest] = [:]
    private var resultsCache: [TestResult] = []

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        testsFileURL = docs.appendingPathComponent("ab_tests.json")
        resultsFileURL = docs.appendingPathComponent("ab_results.json")

        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        loadTests()
        loadResults()
    }

    // MARK: - Tests

    func fetchActiveTests() -> [ABTest] {
        return testsCache.values.filter { $0.active }
    }

    func saveTest(_ test: ABTest) throws {
        testsCache[test.id] = test
        try persistTests()
    }

    // MARK: - Results

    func fetchResults(testID: String) -> [TestResult] {
        return resultsCache.filter { $0.testID == testID }
    }

    func saveResult(_ result: TestResult) throws {
        resultsCache.append(result)
        try persistResults()
    }

    // MARK: - Persistence

    private func loadTests() {
        guard FileManager.default.fileExists(atPath: testsFileURL.path),
              let data = try? Data(contentsOf: testsFileURL),
              let tests = try? decoder.decode([ABTest].self, from: data) else { return }
        testsCache = Dictionary(uniqueKeysWithValues: tests.map { ($0.id, $0) })
    }

    private func loadResults() {
        guard FileManager.default.fileExists(atPath: resultsFileURL.path),
              let data = try? Data(contentsOf: resultsFileURL),
              let results = try? decoder.decode([TestResult].self, from: data) else { return }
        resultsCache = results
    }

    private func persistTests() throws {
        let tests = Array(testsCache.values)
        let data = try encoder.encode(tests)
        try data.write(to: testsFileURL, options: .atomic)
    }

    private func persistResults() throws {
        let data = try encoder.encode(resultsCache)
        try data.write(to: resultsFileURL, options: .atomic)
    }
}