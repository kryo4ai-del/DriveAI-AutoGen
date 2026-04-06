import Foundation

protocol CameraPermissionManagerProtocol {
    func requestAccess() async -> Bool
    func getCurrentStatus() -> Int
    func isAuthorized() -> Bool
}

// Class CameraPermissionManager declared in Models/CameraPermissionManager.swift
