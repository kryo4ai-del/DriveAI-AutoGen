import SwiftUI
import Foundation

protocol LocalDataService: AnyObject {}

class JSONDataService: LocalDataService {}

private struct DataServiceKey: EnvironmentKey {
    static let defaultValue: LocalDataService = JSONDataService()
}

extension EnvironmentValues {
    var dataService: LocalDataService {
        get { self[DataServiceKey.self] }
        set { self[DataServiceKey.self] = newValue }
    }
}