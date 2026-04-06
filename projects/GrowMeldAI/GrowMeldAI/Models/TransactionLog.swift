struct TransactionLog: Codable {
    let transactionID: String
    let productID: String
    let action: String // "purchase", "trial_start", "renew", "cancel"
    let timestamp: Date
    let userID: String?
    let deviceID: String
    let result: String // "success", "pending", "failed"
}

private func logTransaction(
    productID: String,
    transactionID: String,
    action: String,
    result: String = "success"
) {
    let log = TransactionLog(
        transactionID: transactionID,
        productID: productID,
        action: action,
        timestamp: Date(),
        userID: nil, // Populated if you have user accounts
        deviceID: UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
        result: result
    )
    
    // Append to local log file (not UserDefaults, which has size limits)
    appendToTransactionLog(log)
    
    // Send to backend (if backend exists in future) or retain locally for 10 years
}

private func appendToTransactionLog(_ log: TransactionLog) {
    let logsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("subscription_audit_logs")
    
    try? FileManager.default.createDirectory(at: logsURL, withIntermediateDirectories: true)
    
    let logFile = logsURL.appendingPathComponent("transactions_\(Calendar.current.dateComponents([.year, .month], from: Date()).year ?? 0).jsonl")
    
    if let encoded = try? JSONEncoder().encode(log) {
        let jsonLine = String(data: encoded, encoding: .utf8) ?? ""
        try? (jsonLine + "\n").append(toFile: logFile.path, encoding: .utf8)
    }
}