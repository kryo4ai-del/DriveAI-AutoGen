import UIKit

// Service protocol — defined regardless of camera existence
protocol CameraServiceType {
    func requestPermission() async -> Bool
    func startCapture() -> AsyncStream<UIImage>
    func stopCapture() async
}

// Implementation comes only when feature is approved
#if CAMERA_ENABLED
class AVFoundationCameraService: CameraServiceType {
    func requestPermission() async -> Bool { return false }
    func startCapture() -> AsyncStream<UIImage> { return AsyncStream { _ in } }
    func stopCapture() async {}
}
#else
class MockCameraService: CameraServiceType {
    func requestPermission() async -> Bool { return false }
    func startCapture() -> AsyncStream<UIImage> { return AsyncStream { _ in } }
    func stopCapture() async {}
}
#endif

// Injected at app launch
// @main removed - entry point is in DriveAIApp.swift
struct CameraAppBootstrap {
    static func main() {
        #if CAMERA_ENABLED
        let _: CameraServiceType = AVFoundationCameraService()
        #else
        let _: CameraServiceType = MockCameraService()
        #endif
    }
}