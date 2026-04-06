@MainActor
final class AuditLogger: ObservableObject {
    static let shared = AuditLogger()
    
    @Published private(set) var recentLogs: [AuditLogEntry] = []
    
    private let fileManager = FileManager.default
    private let cryptoService = CryptoService.shared
    
    private lazy var auditDirectory: URL = {
        let paths = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        let auditPath = paths[0].appendingPathComponent("DriveAI/Audit")
        try? fileManager.createDirectory(
            at: auditPath,
            withIntermediateDirectories: true
        )
        return auditPath
    }()
    
    private let maxLogsInMemory = 100
    private let retentionDays = 90  // GDPR: retention must be justified
    
    private init() {
        loadRecentLogs()
        cleanupOldLogs()
    }
    
    func log(
        action: String,
        category: ConsentCategory? = nil,
        userId: String,
        details: String? = nil
    ) async {
        let entry = AuditLogEntry(
            action: action,
            category: category,
            userId: userId,
            details: details
        )
        
        // STEP 1: Persist to encrypted file
        do {
            try persistLogEntry(entry)
        } catch {
            // CRITICAL: If audit fails, log to system
            print("⚠️ AUDIT FAILURE: \(error)")
            // In production: report to compliance system
        }
        
        // STEP 2: Keep in memory for UI
        DispatchQueue.main.async {
            self.recentLogs.insert(entry, at: 0)
            if self.recentLogs.count > self.maxLogsInMemory {
                self.recentLogs.removeLast()
            }
        }
    }
    
    // GDPR: Right to data portability
    func exportAuditLog() async throws -> Data {
        let logs = try loadAllLogs()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(logs)
    }
    
    // GDPR: Data retention compliance
    func cleanupOldLogs() {
        guard let files = try? fileManager.contentsOfDirectory(
            at: auditDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else {
            return
        }
        
        let now = Date()
        let retentionDate = Calendar.current.date(
            byAdding: .day,
            value: -retentionDays,
            to: now
        ) ?? now
        
        for file in files {
            if let attrs = try? fileManager.attributesOfItem(atPath: file.path),
               let modDate = attrs[.modificationDate] as? Date,
               modDate < retentionDate {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    // MARK: - Private
    
    private func persistLogEntry(_ entry: AuditLogEntry) throws {
        let encoded = try JSONEncoder().encode(entry)
        let encrypted = try cryptoService.encrypt(encoded)
        
        let fileName = "audit_\(entry.id.uuidString).bin"
        let url = auditDirectory.appendingPathComponent(fileName)
        
        try encrypted.write(to: url)
    }
    
    private func loadRecentLogs() {
        guard let files = try? fileManager.contentsOfDirectory(
            at: auditDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey]
        ) else {
            return
        }
        
        let sortedFiles = files.sorted { a, b in
            let aDate = (try? fileManager.attributesOfItem(atPath: a.path))?[.modificationDate] as? Date ?? Date()
            let bDate = (try? fileManager.attributesOfItem(atPath: b.path))?[.modificationDate] as? Date ?? Date()
            return aDate > bDate
        }
        
        for file in sortedFiles.prefix(maxLogsInMemory) {
            if let data = try? Data(contentsOf: file),
               let decrypted = try? cryptoService.decrypt(data),
               let entry = try? JSONDecoder().decode(AuditLogEntry.self, from: decrypted) {
                recentLogs.append(entry)
            }
        }
    }
    
    private func loadAllLogs() throws -> [AuditLogEntry] {
        guard let files = try? fileManager.contentsOfDirectory(
            at: auditDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        
        var logs: [AuditLogEntry] = []
        for file in files {
            if let data = try? Data(contentsOf: file),
               let decrypted = try? cryptoService.decrypt(data),
               let entry = try? JSONDecoder().decode(AuditLogEntry.self, from: decrypted) {
                logs.append(entry)
            }
        }
        return logs.sorted { $0.timestamp > $1.timestamp }
    }
}