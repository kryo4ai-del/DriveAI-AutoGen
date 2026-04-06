import Foundation
import SQLite3

// MARK: - ABTestRepository Extension

extension ABTestRepository {
    func getAllAssignments() -> [ABTestAssignment] {
        return queue.sync {
            let query = """
            SELECT test_id, variant_id, assigned_at
            FROM ab_assignments
            """
            guard let stmt = database.prepare(query) else { return [] }
            defer { sqlite3_finalize(stmt) }

            var assignments: [ABTestAssignment] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                let testID = String(cString: sqlite3_column_text(stmt, 0))
                let variantID = String(cString: sqlite3_column_text(stmt, 1))
                let assignedAtMS = sqlite3_column_int64(stmt, 2)
                let assignedAt = Date(timeIntervalSince1970: Double(assignedAtMS) / 1000.0)

                assignments.append(ABTestAssignment(
                    testID: testID,
                    variantID: variantID,
                    assignedAt: assignedAt
                ))
            }
            return assignments
        }
    }

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