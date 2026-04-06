import UIKit
import AVFoundation

protocol CameraPreviewProviding {
    func makePreviewLayer() -> CALayer?
}
