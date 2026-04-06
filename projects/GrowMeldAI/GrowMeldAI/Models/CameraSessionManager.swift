// ❌ MISSING: Handle AVCaptureSession.interruptionEnded notification
// When user switches to another app then returns, session may need restart

// ✅ ADD:
class CameraSessionManager {
    override init() {
        super.init()
        subscribeToInterruptionNotifications()
    }
    
    private func subscribeToInterruptionNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionInterruptionEnded),
            name: AVCaptureSession.interruptionEnded,
            object: captureSession
        )
    }
    
    @objc private func sessionInterruptionEnded() {
        sessionQueue.async { [weak self] in
            if !self?.captureSession.isRunning ?? false {
                self?.captureSession.startRunning()
            }
        }
    }
}