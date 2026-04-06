// Shared/Utilities/Logger+Extensions.swift
import os.log

extension Logger {
    static let cameraAccess = Logger(subsystem: "com.driveai.camera", category: "CameraAccess")
}

// Update all services:
// OLD: private static let logger = Logger(...)
// NEW: private static let log = Logger.cameraAccess