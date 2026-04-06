// Shared/Utilities/Logger+Extensions.swift
import os.log

extension Logger {
    static let cameraAccess = Logger(subsystem: "com.driveai.camera", category: "CameraAccess")
    static let permissions = Logger(subsystem: "com.driveai.camera", category: "Permissions")
    static let session = Logger(subsystem: "com.driveai.camera", category: "Session")
}

// Then in services:
import os

final class PermissionManager: PermissionManagerProtocol {
    func requestCameraPermission() async -> CameraPermissionState {
        Logger.permissions.debug("Requesting camera permission")  // ✅ Works
        // ...
    }
}