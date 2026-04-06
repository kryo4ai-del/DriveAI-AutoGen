// Sources/Features/Camera/Services/CameraPermissionService.swift
import AVFoundation
import Foundation

// MARK: - Camera Permission Service Protocol
protocol CameraPermissionServiceProtocol: Sendable {
    func requestCameraAccess() async throws -> CameraPermissionStatus
    func checkCurrentPermissionStatus() -> CameraPermissionStatus
    func openAppSettings() async
}

// MARK: - Camera Permission Service Implementation
@MainActor

// MARK: - Retry Policy