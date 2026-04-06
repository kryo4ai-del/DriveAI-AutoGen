import AVFoundation
import Combine
import UIKit

protocol CameraSessionManagerProtocol: Sendable {
    func startSession() async throws
    func stopSession()
    func captureFrame() -> UIImage?
    var isRunning: Bool { get }
    var framePublisher: PassthroughSubject<UIImage, Never> { get }
}
