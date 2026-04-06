// ❌ MISSING:
enum FocusMode {
    case auto
    case locked
    case manual(CGPoint)
}

// ✅ ADD method:
func setFocusMode(_ mode: FocusMode) async throws {
    guard let device = currentDevice else {
        throw CameraError.focusNotSupported
    }
    
    try device.lockForConfiguration()
    defer { device.unlockForConfiguration() }
    
    switch mode {
    case .auto:
        if device.isFocusModeSupported(.autoFocus) {
            device.focusMode = .autoFocus
        }
    case .locked:
        if device.isFocusModeSupported(.locked) {
            device.focusMode = .locked
        }
    case .manual(let point):
        // Convert CGPoint to device coordinates
        if device.isFocusModeSupported(.autoFocus) {
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
        }
    }
}