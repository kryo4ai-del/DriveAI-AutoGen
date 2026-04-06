import Foundation
import SQLite3

class ABTestRepository {
    let database: DriveAIDatabase
    let queue = DispatchQueue(label: "com.growmeldai.abtestrepository", attributes: .concurrent)

    init(database: DriveAIDatabase) {
        self.database = database
    }

    // MARK: - Test Management
    func getActiveTests() -> [ABTest] {
        return database.fetchActiveTests()
    }

    func saveTest(_ test: ABTest) throws {
        try database.saveTest(test)
    }

    // MARK: - Results Logging
    func logResult(_ result: TestResult) throws {
        try database.saveResult(result)
    }

    func getResults(testID: String) -> [TestResult] {
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

final class DriveAIDatabase {
    private var db: OpaquePointer?
    private let dbQueue = DispatchQueue(label: "com.growmeldai.driveaidatabase")

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbURL = docs.appendingPathComponent("driveai.sqlite")
        if sqlite3_open(dbURL.path, &db) == SQLITE_OK {
            createTables()
        }
    }

    deinit {
        sqlite3_close(db)
    }

    func prepare(_ sql: String) -> OpaquePointer? {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        return stmt
    }

    private func createTables() {
        let testsTable = """
        CREATE TABLE IF NOT EXISTS ab_tests (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            active INTEGER NOT NULL DEFAULT 1,
            variants TEXT NOT NULL DEFAULT '[]',
            created_at INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0
        );
        """
        let resultsTable = """
        CREATE TABLE IF NOT EXISTS ab_results (
            id TEXT PRIMARY KEY,
            test_id TEXT NOT NULL,
            variant_id TEXT NOT NULL,
            user_id_hash TEXT NOT NULL,
            outcome TEXT NOT NULL,
            metadata TEXT,
            timestamp INTEGER NOT NULL DEFAULT 0
        );
        """
        let assignmentsTable = """
        CREATE TABLE IF NOT EXISTS ab_assignments (
            test_id TEXT NOT NULL,
            variant_id TEXT NOT NULL,
            assigned_at INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (test_id)
        );
        """
        execute(testsTable)
        execute(resultsTable)
        execute(assignmentsTable)
    }

    private func execute(_ sql: String) {
        var errMsg: UnsafeMutablePointer<CChar>?
        sqlite3_exec(db, sql, nil, nil, &errMsg)
    }

    // MARK: - Tests

    func fetchActiveTests() -> [ABTest] {
        let query = """
        SELECT id, name, description, active, variants, created_at, updated_at
        FROM ab_tests WHERE active = 1
        """
        guard let stmt = prepare(query) else { return [] }
        defer { sqlite3_finalize(stmt) }

        var tests: [ABTest] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            tests.append(parseTestRow(stmt))
        }
        return tests
    }

    func saveTest(_ test: ABTest) throws {
        let variantsData = (try? JSONEncoder().encode(test.variants)) ?? Data()
        let variantsJSON = String(data: variantsData, encoding: .utf8) ?? "[]"
        let createdAtMS = Int64(test.createdAt.timeIntervalSince1970 * 1000)
        let updatedAtMS = Int64(test.updatedAt.timeIntervalSince1970 * 1000)
        let activeInt: Int32 = test.active ? 1 : 0

        let sql = """
        INSERT OR REPLACE INTO ab_tests (id, name, description, active, variants, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        guard let stmt = prepare(sql) else {
            throw ABTestError.databaseError("Failed to prepare saveTest statement")
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (test.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (test.name as NSString).utf8String, -1, nil)
        if let desc = test.description {
            sqlite3_bind_text(stmt, 3, (desc as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 3)
        }
        sqlite3_bind_int(stmt, 4, activeInt)
        sqlite3_bind_text(stmt, 5, (variantsJSON as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(stmt, 6, createdAtMS)
        sqlite3_bind_int64(stmt, 7, updatedAtMS)

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            throw ABTestError.databaseError("Failed to execute saveTest")
        }
    }

    // MARK: - Results

    func fetchResults(testID: String) -> [TestResult] {
        let query = """
        SELECT id, test_id, variant_id, user_id_hash, outcome, metadata, timestamp
        FROM ab_results WHERE test_id = ?
        """
        guard let stmt = prepare(query) else { return [] }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (testID as NSString).utf8String, -1, nil)

        var results: [TestResult] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            results.append(parseResultRow(stmt))
        }
        return results
    }

    func saveResult(_ result: TestResult) throws {
        let timestampMS = Int64(result.timestamp.timeIntervalSince1970 * 1000)
        let sql = """
        INSERT OR REPLACE INTO ab_results (id, test_id, variant_id, user_id_hash, outcome, metadata, timestamp)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        guard let stmt = prepare(sql) else {
            throw ABTestError.databaseError("Failed to prepare saveResult statement")
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (result.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (result.testID as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 3, (result.variantID as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 4, (result.userIDHash as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 5, (result.outcome as NSString).utf8String, -1, nil)
        if let metadata = result.metadataJSON {
            sqlite3_bind_text(stmt, 6, (metadata as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 6)
        }
        sqlite3_bind_int64(stmt, 7, timestampMS)

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            throw ABTestError.databaseError("Failed to execute saveResult")
        }
    }

    // MARK: - Row Parsers

    func parseTestRow(_ stmt: OpaquePointer) -> ABTest {
        let id = String(cString: sqlite3_column_text(stmt, 0))
        let name = String(cString: sqlite3_column_text(stmt, 1))
        let descPtr = sqlite3_column_text(stmt, 2)
        let description = descPtr != nil ? String(cString: descPtr!) : nil
        let active = sqlite3_column_int(stmt, 3) == 1
        let variantsJSON = String(cString: sqlite3_column_text(stmt, 4))
        let variants = (try? JSONDecoder().decode(
            [TestVariant].self,
            from: variantsJSON.data(using: .utf8) ?? Data()
        )) ?? []
        let createdAtMS = sqlite3_column_int64(stmt, 5)
        let updatedAtMS = sqlite3_column_int64(stmt, 6)

        return ABTest(
            id: id,
            name: name,
            description: description,
            active: active,
            variants: variants,
            createdAt: Date(timeIntervalSince1970: Double(createdAtMS) / 1000.0),
            updatedAt: Date(timeIntervalSince1970: Double(updatedAtMS) / 1000.0)
        )
    }

    func parseResultRow(_ stmt: OpaquePointer) -> TestResult {
        let id = String(cString: sqlite3_column_text(stmt, 0))
        let testID = String(cString: sqlite3_column_text(stmt, 1))
        let variantID = String(cString: sqlite3_column_text(stmt, 2))
        let userIDHash = String(cString: sqlite3_column_text(stmt, 3))
        let outcome = String(cString: sqlite3_column_text(stmt, 4))
        let metadataPtr = sqlite3_column_text(stmt, 5)
        let metadata = metadataPtr != nil ? String(cString: metadataPtr!) : nil
        let timestampMS = sqlite3_column_int64(stmt, 6)

        return TestResult(
            id: id,
            testID: testID,
            variantID: variantID,
            userIDHash: userIDHash,
            outcome: outcome,
            metadataJSON: metadata,
            timestamp: Date(timeIntervalSince1970: Double(timestampMS) / 1000.0)
        )
    }
}

// MARK: - Supporting Model Types

struct ABTest: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let active: Bool
    let variants: [TestVariant]
    let createdAt: Date
    let updatedAt: Date
}

struct TestVariant: Codable, Identifiable {
    let id: String
    let name: String
    let weight: Int
}

struct TestResult: Codable, Identifiable {
    let id: String
    let testID: String
    let variantID: String
    let userIDHash: String
    let outcome: String
    let metadataJSON: String?
    let timestamp: Date

    init(id: String = UUID().uuidString,
         testID: String,
         variantID: String,
         userIDHash: String,
         outcome: String,
         metadataJSON: String? = nil,
         timestamp: Date = Date()) {
        self.id = id
        self.testID = testID
        self.variantID = variantID
        self.userIDHash = userIDHash
        self.outcome = outcome
        self.metadataJSON = metadataJSON
        self.timestamp = timestamp
    }
}

struct ABTestAssignment: Codable {
    let testID: String
    let variantID: String
    let assignedAt: Date
}