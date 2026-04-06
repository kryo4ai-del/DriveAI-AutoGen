import Foundation

// MARK: - Database Models

struct DBRecord: Codable {
    let id: String
    let tableName: String
    let data: Data
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Database Error

enum DatabaseError: Error, LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    case recordNotFound(String)
    case saveFailed(String)
    case deleteFailed(String)
    case directoryCreationFailed(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let msg):    return "Encoding failed: \(msg)"
        case .decodingFailed(let msg):    return "Decoding failed: \(msg)"
        case .recordNotFound(let msg):    return "Record not found: \(msg)"
        case .saveFailed(let msg):        return "Save failed: \(msg)"
        case .deleteFailed(let msg):      return "Delete failed: \(msg)"
        case .directoryCreationFailed(let msg): return "Directory creation failed: \(msg)"
        }
    }
}

// MARK: - Column Expression (Replaces GRDB/SQLite.swift Expression<T>)

/// Lightweight column descriptor replacing SQLite.swift `Expression<T>`
struct Column {
    let name: String

    init(_ name: String) {
        self.name = name
    }
}

// MARK: - Table Definitions

enum Table {
    static let abTests          = "ab_tests"
    static let testVariants     = "test_variants"
    static let testResults      = "test_results"
    static let abTestAssignments = "ab_test_assignments"
}

// MARK: - Column Definitions

enum Columns {
    // Shared
    static let id          = Column("id")
    static let createdAt   = Column("created_at")
    static let updatedAt   = Column("updated_at")

    // ABTest
    static let name        = Column("name")
    static let description = Column("description")
    static let active      = Column("active")

    // TestVariant
    static let testID      = Column("test_id")
    static let percentile  = Column("percentile")

    // TestResult
    static let variantID     = Column("variant_id")
    static let userIDHash    = Column("user_id_hash")
    static let outcome       = Column("outcome")
    static let metadataJSON  = Column("metadata_json")
    static let timestamp     = Column("timestamp")

    // ABTestAssignment
    static let assignedAt  = Column("assigned_at")
}

// MARK: - Database Manager

final class Database {

    // MARK: - Singleton

    static let shared = Database()

    // MARK: - Storage

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.growmeldai.database", attributes: .concurrent)

    private var storageURL: URL {
        guard let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("Cannot locate Application Support directory")
        }
        return appSupport.appendingPathComponent("GrowMeldAI/Database", isDirectory: true)
    }

    // MARK: - Initialiser

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        createDirectoriesIfNeeded()
    }

    // MARK: - Directory Setup

    private func createDirectoriesIfNeeded() {
        let tables = [
            Table.abTests,
            Table.testVariants,
            Table.testResults,
            Table.abTestAssignments
        ]
        for table in tables {
            let dir = storageURL.appendingPathComponent(table, isDirectory: true)
            if !fileManager.fileExists(atPath: dir.path) {
                try? fileManager.createDirectory(
                    at: dir,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }
        }
    }

    // MARK: - URL Helpers

    private func tableURL(for table: String) -> URL {
        storageURL.appendingPathComponent(table, isDirectory: true)
    }

    private func recordURL(for table: String, id: String) -> URL {
        tableURL(for: table).appendingPathComponent("\(id).json")
    }

    // MARK: - Generic CRUD

    func save<T: Codable & Identifiable>(_ record: T, to table: String) throws where T.ID == String {
        let data = try encoder.encode(record)
        let url = recordURL(for: table, id: record.id)
        try data.write(to: url, options: .atomic)
    }

    func fetch<T: Codable>(id: String, from table: String) throws -> T {
        let url = recordURL(for: table, id: id)
        guard fileManager.fileExists(atPath: url.path) else {
            throw DatabaseError.recordNotFound("No record with id '\(id)' in '\(table)'")
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }

    func fetchAll<T: Codable>(from table: String) throws -> [T] {
        let dir = tableURL(for: table)
        guard fileManager.fileExists(atPath: dir.path) else { return [] }
        let files = try fileManager.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        return try files.compactMap { url in
            let data = try Data(contentsOf: url)
            return try? decoder.decode(T.self, from: data)
        }
    }

    func delete(id: String, from table: String) throws {
        let url = recordURL(for: table, id: id)
        guard fileManager.fileExists(atPath: url.path) else {
            throw DatabaseError.recordNotFound("No record with id '\(id)' in '\(table)'")
        }
        try fileManager.removeItem(at: url)
    }

    func deleteAll(from table: String) throws {
        let dir = tableURL(for: table)
        guard fileManager.fileExists(atPath: dir.path) else { return }
        let files = try fileManager.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        for file in files {
            try fileManager.removeItem(at: file)
        }
    }

    // MARK: - ABTest Operations

    func saveABTest(_ test: ABTest) throws {
        try save(test, to: Table.abTests)
    }

    func fetchABTest(id: String) throws -> ABTest {
        try fetch(id: id, from: Table.abTests)
    }

    func fetchAllABTests() throws -> [ABTest] {
        try fetchAll(from: Table.abTests)
    }

    func fetchActiveABTests() throws -> [ABTest] {
        let all: [ABTest] = try fetchAll(from: Table.abTests)
        return all.filter { $0.active }
    }

    func deleteABTest(id: String) throws {
        try delete(id: id, from: Table.abTests)
    }

    // MARK: - TestVariant Operations

    func saveTestVariant(_ variant: TestVariant) throws {
        try save(variant, to: Table.testVariants)
    }

    func fetchTestVariant(id: String) throws -> TestVariant {
        try fetch(id: id, from: Table.testVariants)
    }

    func fetchAllTestVariants() throws -> [TestVariant] {
        try fetchAll(from: Table.testVariants)
    }

    func deleteTestVariant(id: String) throws {
        try delete(id: id, from: Table.testVariants)
    }

    // MARK: - TestResult Operations

    func saveTestResult(_ result: TestResult) throws {
        try save(result, to: Table.testResults)
    }

    func fetchTestResult(id: String) throws -> TestResult {
        try fetch(id: id, from: Table.testResults)
    }

    func fetchAllTestResults() throws -> [TestResult] {
        try fetchAll(from: Table.testResults)
    }

    func fetchTestResults(forTestID testID: String) throws -> [TestResult] {
        let all: [TestResult] = try fetchAll(from: Table.testResults)
        return all.filter { $0.testID == testID }
    }

    func fetchTestResults(forVariantID variantID: String) throws -> [TestResult] {
        let all: [TestResult] = try fetchAll(from: Table.testResults)
        return all.filter { $0.variantID == variantID }
    }

    func deleteTestResult(id: String) throws {
        try delete(id: id, from: Table.testResults)
    }

    func deleteAllTestResults(forTestID testID: String) throws {
        let results = try fetchTestResults(forTestID: testID)
        for result in results {
            try delete(id: result.id, from: Table.testResults)
        }
    }

    // MARK: - ABTestAssignment Operations

    func saveAssignment(_ assignment: ABTestAssignment) throws {
        // Use testID as file key since assignments are 1-per-test
        let data = try encoder.encode(assignment)
        let url = recordURL(for: Table.abTestAssignments, id: assignment.testID)
        try data.write(to: url, options: .atomic)
    }

    func fetchAssignment(forTestID testID: String) throws -> ABTestAssignment {
        let url = recordURL(for: Table.abTestAssignments, id: testID)
        guard fileManager.fileExists(atPath: url.path) else {
            throw DatabaseError.recordNotFound("No assignment for testID '\(testID)'")
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(ABTestAssignment.self, from: data)
    }

    func fetchAllAssignments() throws -> [ABTestAssignment] {
        let dir = tableURL(for: Table.abTestAssignments)
        guard fileManager.fileExists(atPath: dir.path) else { return [] }
        let files = try fileManager.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        return try files.compactMap { url in
            let data = try Data(contentsOf: url)
            return try? decoder.decode(ABTestAssignment.self, from: data)
        }
    }

    func deleteAssignment(forTestID testID: String) throws {
        try delete(id: testID, from: Table.abTestAssignments)
    }

    // MARK: - Async Wrappers

    func saveABTestAsync(_ test: ABTest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async(flags: .barrier) {
                do {
                    try self.saveABTest(test)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchAllABTestsAsync() async throws -> [ABTest] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let tests = try self.fetchAllABTests()
                    continuation.resume(returning: tests)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func saveTestResultAsync(_ result: TestResult) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async(flags: .barrier) {
                do {
                    try self.saveTestResult(result)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchTestResultsAsync(forTestID testID: String) async throws -> [TestResult] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let results = try self.fetchTestResults(forTestID: testID)
                    continuation.resume(returning: results)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Statistics

    struct VariantStats {
        let variantID: String
        let totalResults: Int
        let passCount: Int
        let failCount: Int
        var passRate: Double {
            guard totalResults > 0 else { return 0 }
            return Double(passCount) / Double(totalResults)
        }
    }

    func computeStats(forTestID testID: String) throws -> [VariantStats] {
        let results = try fetchTestResults(forTestID: testID)
        var grouped: [String: [TestResult]] = [:]
        for result in results {
            grouped[result.variantID, default: []].append(result)
        }
        return grouped.map { variantID, variantResults in
            let passCount = variantResults.filter { $0.outcome == "pass" }.count
            let failCount = variantResults.filter { $0.outcome == "fail" }.count
            return VariantStats(
                variantID: variantID,
                totalResults: variantResults.count,
                passCount: passCount,
                failCount: failCount
            )
        }.sorted { $0.variantID < $1.variantID }
    }

    // MARK: - Purge / Reset

    func purgeAll() throws {
        let tables = [
            Table.abTests,
            Table.testVariants,
            Table.testResults,
            Table.abTestAssignments
        ]
        for table in tables {
            try? deleteAll(from: table)
        }
    }
}