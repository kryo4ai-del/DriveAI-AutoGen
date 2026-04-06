import AVFoundation
import Combine

protocol CameraSessionProviding: AnyObject {
    var isRunning: AnyPublisher<Bool, Never> { get }
    var currentDevicePosition: AnyPublisher<AVCaptureDevice.Position, Never> { get }
    var availableDevices: [AVCaptureDevice] { get }
    
    func startSession() async throws
    func stopSession() async
    func switchCamera(to position: AVCaptureDevice.Position) async throws
}