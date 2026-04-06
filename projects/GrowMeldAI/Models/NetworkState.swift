import Foundation
import Network
import Combine

enum NetworkState: Equatable {
    case connected(NetworkType)
    case disconnected
    case unsure
    
    enum NetworkType {
        case wifi
        case cellular
        case unknown
    }
}
