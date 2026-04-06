enum LocationDataError: LocalizedError {
    case bundleFileNotFound(String)
    case invalidData
    case decodingFailed(String)
}

enum LocationRepositoryError: LocalizedError {
    case saveFailed
    case encodingFailed
}