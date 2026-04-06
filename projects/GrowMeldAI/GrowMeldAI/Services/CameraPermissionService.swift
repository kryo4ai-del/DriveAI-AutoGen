/// Service for managing camera permissions with retry logic.
/// 
/// - Note: Runs on MainActor because AVCaptureDevice.requestAccess()
///   must be called from the main thread.
@MainActor
final class CameraPermissionService: CameraPermissionServiceProtocol { }