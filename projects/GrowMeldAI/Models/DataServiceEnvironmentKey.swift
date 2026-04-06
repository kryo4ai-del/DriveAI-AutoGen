import SwiftUI
import Foundation

protocol LocalDataService: AnyObject {}

class JSONDataService: LocalDataService {}

private struct DataServiceEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyObject = JSONDataService()
}

extension EnvironmentValues {
    var dataService: LocalDataService {
        get {
            if let service = self[DataServiceEnvironmentKey.self] as? LocalDataService {
                return service
            }
            return JSONDataService()
        }
        set {
            // no-op: environment key uses defaultValue
        }
    }
}