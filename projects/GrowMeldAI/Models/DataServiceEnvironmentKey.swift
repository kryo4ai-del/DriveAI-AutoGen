import SwiftUI

struct DataServiceEnvironmentKey: EnvironmentKey {
    static let defaultValue: LocalDataService = JSONDataService()
}

extension EnvironmentValues {
    var dataService: LocalDataService {
        get { self[DataServiceEnvironmentKey.self] }
        set { self[DataServiceEnvironmentKey.self] = newValue }
    }
}