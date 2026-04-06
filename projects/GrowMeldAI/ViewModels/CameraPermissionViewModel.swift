import SwiftUI
import Combine

@MainActor
final class CameraPermissionViewModel: ObservableObject {
    @Published var hasPermission = false
    @Published var showSettingsAlert = false
    init() {}
    func requestCameraAccess() {}
    func openSettings() {}
}
