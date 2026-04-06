// Services/CameraAccess/CameraAccessManagerProtocol.swift

import AVFoundation

/// Protocol defining camera permission management interface
@MainActor
protocol CameraAccessManagerProtocol: AnyObject {
    /// Current permission state (cached)
    var permissionState: PermissionState { get }
    
    /// Check current permission without requesting
    func checkPermission() async -> PermissionState
    
    /// Request permission from user
    func requestPermission() async -> PermissionState
    
    /// Clear cached permission state
    func resetPermissionCache()
    
    /// Refresh permission state on app foreground
    func invalidateCacheOnForeground()
}

// MARK: - Permission State
