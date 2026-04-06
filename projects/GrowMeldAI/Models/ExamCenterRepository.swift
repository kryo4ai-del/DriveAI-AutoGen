final class ExamCenterRepository: ObservableObject {
    func loadCenters(from source: DataSource) async throws -> [ExamCenter] {
        switch source {
        case .bundleJSON:
            return try loadFromBundle("exam-centers.json")
        case .cache:
            return try loadFromUserDefaults()
        }
    }
}