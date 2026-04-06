import AVFoundation

protocol CameraFrameDelegate: AnyObject {
    func didCaptureFrame(_ frame: CMSampleBuffer)
    func didFailWithError(_ error: Error)
}