import AVFoundation

enum CameraSessionState: Equatable {
    case idle
    case initializing
    case running
    case stopping
    case failed(Error)
    
    var isRunning: Bool {
        self == .running
    }
    
    static func == (lhs: CameraSessionState, rhs: CameraSessionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.initializing, .initializing),
             (.running, .running), (.stopping, .stopping):
            return true
        case (.failed, .failed):
            return true // Simplified for comparison
        default:
            return false
        }
    }
}