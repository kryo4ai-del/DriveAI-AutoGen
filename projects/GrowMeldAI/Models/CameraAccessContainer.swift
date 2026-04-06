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