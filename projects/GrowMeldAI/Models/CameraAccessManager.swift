// Features/Camera/Services/CameraAccessManager.swift
import AVFoundation
import os.log

protocol CameraAccessManager: AnyObject, Sendable {
    func checkCameraPermission() -> CameraPermissionStatus
    func requestCameraPermission() async -> CameraPermissionStatus
    func openAppSettings()
}