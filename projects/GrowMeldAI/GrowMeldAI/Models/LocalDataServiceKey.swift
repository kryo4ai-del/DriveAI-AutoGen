private struct LocalDataServiceKey: EnvironmentKey {
    static let defaultValue: LocalDataServiceProtocol = LocalDataService()
}

extension EnvironmentValues {
    var localDataService: LocalDataServiceProtocol {
        get { self[LocalDataServiceKey.self] }
        set { self[LocalDataServiceKey.self] = newValue }
    }
}