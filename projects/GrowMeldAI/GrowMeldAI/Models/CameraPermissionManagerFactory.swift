final class CameraPermissionManagerFactory {
    static private var instance: CameraPermissionManager?
    
    static func shared() -> CameraPermissionManager {
        if instance == nil {
            instance = CameraPermissionManager()
        }
        return instance!
    }
    
    static func setShared(_ manager: CameraPermissionManager) {
        instance = manager
    }
}