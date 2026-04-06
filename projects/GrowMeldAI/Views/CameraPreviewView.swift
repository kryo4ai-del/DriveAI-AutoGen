import SwiftUI
import AVFoundation

struct CameraPreviewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> PreviewUIView {
        PreviewUIView()
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

class PreviewUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    private let session = AVCaptureSession()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSession()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSession()
    }

    private func setupSession() {
        session.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
}

struct FocusIndicatorView: View {
    @State private var isVisible = false

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(Color.yellow, lineWidth: 2)
            .frame(width: 80, height: 80)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}

struct CameraPreviewView: View {
    var body: some View {
        ZStack {
            CameraPreviewRepresentable()
                .accessibilityLabel("Kamera-Vorschau für Dokumenterfassung")
                .accessibilityHint("Tippe zum Fokussieren auf ein bestimmtes Objekt. Nutze zwei Finger zum Zoomen. Doppeltippe zum Erfassen.")
                .accessibilityElement(children: .combine)

            FocusIndicatorView()
                .accessibilityHidden(true)
        }
    }
}