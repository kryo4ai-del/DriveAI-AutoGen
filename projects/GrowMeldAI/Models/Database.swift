import Foundation

// MARK: - Database Models

struct DBRecord: Codable {
    let id: String
    let tableName: String
    let data: Data
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Column Expression

struct Column {
    let name: String

    init(_ name: String) {
        self.name = name
    }
}

// MARK: - Table Definitions

enum Table {
    static let abTests           = "ab_tests"
    static let testVariants      = "test_variants"
    static let testResults       = "test_results"
    static let abTestAssignments = "ab_test_assignments"
}

// MARK: - Column Definitions

enum Columns {
    static let id           = Column("id")
    static let createdAt    = Column("created_at")
    static let updatedAt    = Column("updated_at")
    static let name         = Column("name")
    static let description  = Column("description")
    static let active       = Column("active")
    static let testID       = Column("test_id")
    static let percentile   = Column("percentile")
    static let variantID    = Column("variant_id")
    static let userIDHash   = Column("user_id_hash")
    static let outcome      = Column("outcome")
    static let metadataJSON = Column("metadata_json")
    static let timestamp    = Column("timestamp")
    static let assignedAt   = Column("assigned_at")
}

// MARK: - Local Error Type

private enum DBInternalError: Error, LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    case recordNotFound(String)
    case saveFailed(String)
    case deleteFailed(String)
    case directoryCreationFailed(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let msg):          return "Encoding failed: \(msg)"
        case .decodingFailed(let msg):          return "Decoding failed: \(msg)"
        case .recordNotFound(let msg):          return "Record not found: \(msg)"
        case .saveFailed(let msg):              return "Save failed: \(msg)"
        case .deleteFailed(let msg):            return "Delete failed: \(msg)"
        case .directoryCreationFailed(let msg): return "Directory creation failed: \(msg)"
        }
    }
}

// MARK: - ABTest Model

struct ABTest: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let active: Bool
    let createdAt: Date
    let updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        active: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.active = active
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - TestVariant Model

struct TestVariant: Codable, Identifiable {
    let id: String
    let testID: String
    let name: String
    let percentile: Double
    let createdAt: Date
    let updatedAt: Date

    init(
        id: String = UUID().uuidString,
        testID: String,
        name: String,
        percentile: Double,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.testID = testID
        self.name = name
        self.percentile = percentile
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - TestResult Model

struct TestResult: Codable, Identifiable {
    let id: String
    let variantID: String
    let userIDHash: String
    let outcome: String
    let metadataJSON: String
    let timestamp: Date
    let createdAt: Date
    let updatedAt: Date

    init(
        id: String = UUID().uuidString,
        variantID: String,
        userIDHash: String,
        outcome: String,
        metadataJSON: String = "{}",
        timestamp: Date = Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.variantID = variantID
        self.userIDHash = userIDHash
        self.outcome = outcome
        self.metadataJSON = metadataJSON
        self.timestamp = timestamp
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - ABTestAssignment Model

struct ABTestAssignment: Codable, Identifiable {
    let id: String
    let testID: String
    let variantID: String
    let userIDHash: String
    let assignedAt: Date
    let createdAt: Date
    let updatedAt: Date

    init(
        id: String = UUID().uuidString,
        testID: String,
        variantID: String,
        userIDHash: String,
        assignedAt: Date = Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.testID = testID
        self.variantID = variantID
        self.userIDHash = userIDHash
        self.assignedAt = assignedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
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

    func save<T: Codable>(_ record: T, id: String, table: String) throws {
        let data = try encoder.encode(record)
        let url = recordURL(for: table, id: id)
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw DBInternalError.saveFailed(error.localizedDescription)
        }
    }

    func load<T: Codable>(_ type: T.Type, id: String, table: String) throws -> T {
        let url = recordURL(for: table, id: id)
        guard fileManager.fileExists(atPath: url.path) else {
            throw DBInternalError.recordNotFound("id=\(id) in \(table)")
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(type, from: data)
        } catch let error as DBInternalError {
            throw error
        } catch {
            throw DBInternalError.decodingFailed(error.localizedDescription)
        }
    }

    func loadAll<T: Codable>(_ type: T.Type, table: String) throws -> [T] {
        let dir = tableURL(for: table)
        guard fileManager.fileExists(atPath: dir.path) else { return [] }
        let files = (try? fileManager.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil
        )) ?? []
        return files.compactMap { url in
            guard let data = try? Data(contentsOf: url) else { return nil }
            return try? decoder.decode(type, from: data)
        }
    }

    func delete(id: String, table: String) throws {
        let url = recordURL(for: table, id: id)
        guard fileManager.fileExists(atPath: url.path) else {
            throw DBInternalError.recordNotFound("id=\(id) in \(table)")
        }
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw DBInternalError.deleteFailed(error.localizedDescription)
        }
    }

    func exists(id: String, table: String) -> Bool {
        fileManager.fileExists(atPath: recordURL(for: table, id: id).path)
    }

    // MARK: - ABTest Operations

    func saveABTest(_ test: ABTest) throws {
        try save(test, id: test.id, table: Table.abTests)
    }

    func loadABTest(id: String) throws -> ABTest {
        try load(ABTest.self, id: id, table: Table.abTests)
    }

    func loadAllABTests() throws -> [ABTest] {
        try loadAll(ABTest.self, table: Table.abTests)
    }

    func deleteABTest(id: String) throws {
        try delete(id: id, table: Table.abTests)
    }

    // MARK: - TestVariant Operations

    func saveTestVariant(_ variant: TestVariant) throws {
        try save(variant, id: variant.id, table: Table.testVariants)
    }

    func loadTestVariant(id: String) throws -> TestVariant {
        try load(TestVariant.self, id: id, table: Table.testVariants)
    }

    func loadAllTestVariants() throws -> [TestVariant] {
        try loadAll(TestVariant.self, table: Table.testVariants)
    }

    func loadTestVariants(for testID: String) throws -> [TestVariant] {
        let all = try loadAllTestVariants()
        return all.filter { $0.testID == testID }
    }

    func deleteTestVariant(id: String) throws {
        try delete(id: id, table: Table.testVariants)
    }

    // MARK: - TestResult Operations

    func saveTestResult(_ result: TestResult) throws {
        try save(result, id: result.id, table: Table.testResults)
    }

    func loadTestResult(id: String) throws -> TestResult {
        try load(TestResult.self, id: id, table: Table.testResults)
    }

    func loadAllTestResults() throws -> [TestResult] {
        try loadAll(TestResult.self, table: Table.testResults)
    }

    func loadTestResults(for variantID: String) throws -> [TestResult] {
        let all = try loadAllTestResults()
        return all.filter { $0.variantID == variantID }
    }

    func deleteTestResult(id: String) throws {
        try delete(id: id, table: Table.testResults)
    }

    // MARK: - ABTestAssignment Operations

    func saveABTestAssignment(_ assignment: ABTestAssignment) throws {
        try save(assignment, id: assignment.id, table: Table.abTestAssignments)
    }

    func loadABTestAssignment(id: String) throws -> ABTestAssignment {
        try load(ABTestAssignment.self, id: id, table: Table.abTestAssignments)
    }

    func loadAllABTestAssignments() throws -> [ABTestAssignment] {
        try loadAll(ABTestAssignment.self, table: Table.abTestAssignments)
    }

    func loadABTestAssignment(testID: String, userIDHash: String) throws -> ABTestAssignment {
        let all = try loadAllABTestAssignments()
        guard let found = all.first(where: { $0.testID == testID && $0.userIDHash == userIDHash }) else {
            throw DBInternalError.recordNotFound("testID=\(testID) userIDHash=\(userIDHash)")
        }
        return found
    }

    func deleteABTestAssignment(id: String) throws {
        try delete(id: id, table: Table.abTestAssignments)
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

    func loadAllABTestsAsync() async throws -> [ABTest] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[ABTest], Error>) in
            queue.async {
                do {
                    let tests = try self.loadAllABTests()
                    continuation.resume(returning: tests)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}