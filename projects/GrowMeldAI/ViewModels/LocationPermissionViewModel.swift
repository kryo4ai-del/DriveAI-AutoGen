import Foundation
import Combine

@MainActor
class LocationPermissionViewModel: ObservableObject {
    @Published var shouldShowPermissionRequest: Bool = false
    func requestPermission() {}
    init() {}
}
