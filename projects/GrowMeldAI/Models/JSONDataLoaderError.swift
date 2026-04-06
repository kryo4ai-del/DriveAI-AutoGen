enum JSONDataLoaderError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(DecodingError)
    case emptyData
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Datei nicht gefunden: \(filename)"
        case .decodingFailed(let error):
            return "Fehler beim Laden der Daten: \(error.localizedDescription)"
        case .emptyData:
            return "Keine Fragen verfügbar"
        }
    }
}
