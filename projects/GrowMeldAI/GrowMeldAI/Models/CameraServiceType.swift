// Service protocol — defined regardless of camera existence
protocol CameraServiceType {
    func requestPermission() async -> Bool
    func startCapture() -> AsyncStream<UIImage>
    func stopCapture() async
}

// Implementation comes only when feature is approved
#if CAMERA_ENABLED
class AVFoundationCameraService: CameraServiceType {
    // Implementation details
}
#else
class MockCameraService: CameraServiceType {
    // For testing MVP without camera
}
#endif

// Injected at app launch
@main