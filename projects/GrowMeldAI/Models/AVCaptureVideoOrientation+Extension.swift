import AVFoundation
import UIKit
extension AVCaptureVideoOrientation {
    init?(_ deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        case .faceUp, .faceDown, .unknown:
            return nil
        @unknown default:
            return nil
        }
    }
}