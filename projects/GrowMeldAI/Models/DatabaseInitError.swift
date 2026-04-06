enum DatabaseInitError: LocalizedError {
    case bundledDatabaseNotFound
    case corruptedDatabase
    case diskSpaceExhausted
    
    var errorDescription: String? {
        switch self {
        case .bundledDatabaseNotFound:
            return "Datenbank konnte nicht initialisiert werden. Bitte installieren Sie die App erneut."
        case .corruptedDatabase:
            return "Datenbankdatei ist beschädigt. Bitte deinstallieren und neu installieren."
        case .diskSpaceExhausted:
            return "Nicht genug Speicherplatz. Bitte geben Sie Speicherplatz frei."
        }
    }
}

func initializeDatabase() async throws {
    let fileManager = FileManager.default
    
    guard let bundledPath = Bundle.main.path(forResource: "driveai", ofType: "db") else {
        throw DatabaseInitError.bundledDatabaseNotFound
    }
    
    do {
        try fileManager.copyItem(atPath: bundledPath, toPath: dbPath)
    } catch {
        if error.localizedDescription.contains("space") {
            throw DatabaseInitError.diskSpaceExhausted
        }
        throw DatabaseInitError.corruptedDatabase
    }
}