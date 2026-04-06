import Foundation

protocol PermissionManagerProtocol: AnyObject {
    func requestCameraPermission(completion: @escaping (Bool) -> Void)
}

protocol CameraSessionManagerProtocol: AnyObject {
    func startSession()
    func stopSession()
}

protocol SignRecognitionServiceProtocol: AnyObject {
    func recognize(completion: @escaping (String?) -> Void)
}

final class PermissionManager: PermissionManagerProtocol {
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}

final class CameraSessionManager: CameraSessionManagerProtocol {
    func startSession() {}
    func stopSession() {}
}

final class SignRecognitionService: SignRecognitionServiceProtocol {
    init() {}
    func recognize(completion: @escaping (String?) -> Void) {
        completion(nil)
    }
}

final class MockPermissionManager: PermissionManagerProtocol {
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}

final class MockCameraSessionManager: CameraSessionManagerProtocol {
    func startSession() {}
    func stopSession() {}
}

final class MockSignRecognitionService: SignRecognitionServiceProtocol {
    func recognize(completion: @escaping (String?) -> Void) {
        completion(nil)
    }
}

struct CameraAccessContainer {
    let permissionManager: PermissionManagerProtocol
    let cameraSessionManager: CameraSessionManagerProtocol
    let signRecognitionService: SignRecognitionServiceProtocol

    static func production() -> Self {
        Self(
            permissionManager: PermissionManager(),
            cameraSessionManager: CameraSessionManager(),
            signRecognitionService: SignRecognitionService()
        )
    }

    static func testing() -> Self {
        Self(
            permissionManager: MockPermissionManager(),
            cameraSessionManager: MockCameraSessionManager(),
            signRecognitionService: MockSignRecognitionService()
        )
    }
}