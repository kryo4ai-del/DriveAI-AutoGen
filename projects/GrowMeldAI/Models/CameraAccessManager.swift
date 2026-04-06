// Features/Camera/Services/CameraAccessManager.swift
import AVFoundation
import os.log

enum CameraPermissionStatus: Sendable {
    case authorized
    case denied
    case restricted
    case notDetermined
}

protocol CameraAccessManager: AnyObject, Sendable {
    func checkCameraPermission() -> CameraPermissionStatus
    func requestCameraPermission() async -> CameraPermissionStatus
    func openAppSettings()
}