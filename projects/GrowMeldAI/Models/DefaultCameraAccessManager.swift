@MainActor
final class DefaultCameraAccessManager: CameraAccessManager {
    private let logger: Logger
    
    init(logger: Logger = Logger(subsystem: "com.driveai.camera", 
                                  category: "CameraAccessManager")) {
        self.logger = logger
    }
    
    // Benefits: Testable logger injection, explicit dependencies
}