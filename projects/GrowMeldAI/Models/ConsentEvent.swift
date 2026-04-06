import Foundation

enum ConsentEvent: String {
    case granted
    case revoked
    case requested
    case failed
}

private struct ConsentLogEntry: Codable {
    let event: String
    let timestamp: Date
}

final class ConsentAuditLog {
    private let persistenceKey = "com.driveai.consent.auditLog"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func logEvent(_ event: String, timestamp: Date) async {
        let logEntry = ConsentLogEntry(event: event, timestamp: timestamp)
        var entries = loadEntries()
        entries.append(logEntry)
        saveEntries(entries)
    }

    private func loadEntries() -> [ConsentLogEntry] {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey),
              let entries = try? decoder.decode([ConsentLogEntry].self, from: data) else {
            return []
        }
        return entries
    }

    private func saveEntries(_ entries: [ConsentLogEntry]) {
        guard let data = try? encoder.encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: persistenceKey)
    }
}