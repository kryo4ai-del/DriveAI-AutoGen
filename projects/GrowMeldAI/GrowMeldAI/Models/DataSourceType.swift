enum DataSourceType: DataSource {
    case bundleJSON(filename: String = "exam-centers")
    case mock([ExamCenter])
    
    func fetch() async throws -> [ExamCenter] {
        switch self {
        case .bundleJSON(let filename):
            return try loadFromBundle(filename)  // ❌ Not defined
        case .mock(let centers):
            return centers
        }
    }
}
// ❌ loadFromBundle() function is missing