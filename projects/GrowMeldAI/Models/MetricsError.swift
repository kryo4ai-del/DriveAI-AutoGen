enum MetricsError: LocalizedError {
    case invalidExamDate(String)
    case corruptedData(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidExamDate(let msg), .corruptedData(let msg):
            return msg
        }
    }
}