final class LocalPurchaseStore {
    private let dataService: LocalDataService
    
    private let tableName = "purchases"
    private let createTableSQL = """
        CREATE TABLE IF NOT EXISTS purchases (
            id TEXT PRIMARY KEY,
            featureId TEXT NOT NULL,
            purchaseDate REAL NOT NULL,
            expiryDate REAL,
            receiptData TEXT NOT NULL,
            verificationState TEXT NOT NULL,
            createdAt REAL NOT NULL DEFAULT (strftime('%s', 'now'))
        )
    """
    
    init(dataService: LocalDataService) {
        self.dataService = dataService
        Task { try? await initializeSchema() }
    }
    
    func initializeSchema() async throws {
        try await dataService.execute(createTableSQL)
    }
    
    func savePurchase(_ transaction: PurchaseTransaction) async throws {
        let params: [Any] = [
            transaction.id,
            transaction.featureId,
            transaction.purchaseDate.timeIntervalSince1970,
            transaction.expiryDate?.timeIntervalSince1970 ?? NSNull(),
            transaction.receiptData,
            transaction.verificationState.rawValue,
            Date().timeIntervalSince1970
        ]
        
        try await dataService.execute(
            """
            INSERT OR REPLACE INTO purchases
            (id, featureId, purchaseDate, expiryDate, receiptData, verificationState, createdAt)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            parameters: params
        )
    }
    
    func fetchTransactions() async throws -> [PurchaseTransaction] {
        let rows = try await dataService.query(
            "SELECT * FROM purchases WHERE verificationState = ? ORDER BY purchaseDate DESC",
            parameters: [PurchaseTransaction.VerificationState.verified.rawValue]
        )
        
        return rows.compactMap { row in
            PurchaseTransaction(
                id: row["id"] as? String ?? "",
                featureId: row["featureId"] as? String ?? "",
                purchaseDate: Date(timeIntervalSince1970: row["purchaseDate"] as? Double ?? 0),
                expiryDate: (row["expiryDate"] as? Double).map { Date(timeIntervalSince1970: $0) },
                receiptData: row["receiptData"] as? String ?? "",
                verificationState: PurchaseTransaction.VerificationState(
                    rawValue: row["verificationState"] as? String ?? "unverified"
                ) ?? .unverified
            )
        }
    }
}