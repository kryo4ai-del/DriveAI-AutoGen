import Foundation

protocol CameraPermissionManagerProtocol {
    func requestAccess() async -> Bool
    func getCurrentStatus() -> Int
    func isAuthorized() -> Bool
}

@MainActor
class CameraPermissionManager: CameraPermissionManagerProtocol {
    func requestAccess() async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                continuation.resume(returning: true)
            }
        }
    }

    func getCurrentStatus() -> Int {
        return 3
    }

    func isAuthorized() -> Bool {
        return true
    }
}