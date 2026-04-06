enum EventStoreError: LocalizedError {
    case fileNotFound
    case ioError(Error)
    case decodingError(Error)
    case diskFull
    case invalidPath
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Events file not found (will create on next save)"
        case .ioError(let error):
            return "Disk I/O error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Event file corrupted: \(error.localizedDescription)"
        case .diskFull:
            return "Disk space full — cannot save events"
        case .invalidPath:
            return "Invalid events directory path"
        }
    }
}
