// Add to Utilities/EnvironmentKeys.swift
struct DataServiceKey: EnvironmentKey {
    static let defaultValue: LocalDataService = JSONDataService()
}

extension EnvironmentValues {
    var dataService: LocalDataService {
        get { self[DataServiceKey.self] }
        set { self[DataServiceKey.self] = newValue }
    }
}