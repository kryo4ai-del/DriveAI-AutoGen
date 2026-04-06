import SwiftUI
import AVFoundation
import Vision
import Combine

// MARK: - View
struct PlantRecognitionCameraView: View {
    @StateObject private var viewModel = PlantRecognitionCameraViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreview(session: viewModel.captureSession)
                .ignoresSafeArea()
                .onAppear {
                    viewModel.startSession()
                }
                .onDisappear {
                    viewModel.stopSession()
                }

            // Overlay UI
            VStack(spacing: 0) {
                // Header with motivational message
                VStack(spacing: 8) {
                    Text("Fotografier eine Pflanze aus dem Theorievideo")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)

                    Text("Wir zeigen dir, was du wissen musst!")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                Spacer()

                // Capture Button
                Button(action: {
                    viewModel.capturePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 4)
                        )
                }
                .padding(.bottom, 40)

                // Status Message
                if let status = viewModel.statusMessage {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Abbrechen", role: .cancel) {
                    dismiss()
                }
                .foregroundStyle(.white)
            }
        }
        .alert("Erkennung fehlgeschlagen", isPresented: $viewModel.showRecognitionError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Leider konnten wir die Pflanze nicht erkennen. Bitte versuche es mit einem anderen Bild.")
        }
        .sheet(isPresented: $viewModel.showResultView) {
            if let result = viewModel.recognitionResult {
                PlantRecognitionResultView(result: result)
            }
        }
    }
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.masksToBounds = true

        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

// MARK: - ViewModel
final class PlantRecognitionCameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var statusMessage: String?
    @Published var showRecognitionError = false
    @Published var showResultView = false
    @Published var recognitionResult: PlantRecognitionResult?

    let captureSession = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let videoDeviceInput: AVCaptureDeviceInput
    private let recognitionQueue = DispatchQueue(label: "com.driveai.plantrecognition.queue")

    override init() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            fatalError("No back camera available")
        }

        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: device)
        } catch {
            fatalError("Failed to create camera input: \(error)")
        }

        super.init()

        setupSession()
    }

    private func setupSession() {
        captureSession.sessionPreset = .photo

        do {
            // Add video input
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
            } else {
                fatalError("Could not add video device input")
            }

            // Add photo output
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            } else {
                fatalError("Could not add photo output")
            }
        }
    }

    func startSession() {
        if captureSession.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
        statusMessage = "Erkenne Pflanze..."
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            showRecognitionError = true
            return
        }

        recognizePlant(in: uiImage)
    }

    private func recognizePlant(in image: UIImage) {
        statusMessage = "Analysiere Pflanze..."

        recognitionQueue.async { [weak self] in
            guard let self = self else { return }

            // Simulate recognition delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // In a real app, this would use Vision framework with a plant classifier model
                let mockResult = PlantRecognitionResult(
                    plantName: "Löwenzahn",
                    confidence: 0.92,
                    description: "Häufige Pflanze auf Wiesen und Wegrändern. Wird oft mit Löwenzahn verwechselt.",
                    relatedTheory: "Im Theorievideo 'Verkehrszeichen und Pflanzen' behandelt."
                )

                DispatchQueue.main.async {
                    self.recognitionResult = mockResult
                    self.showResultView = true
                    self.statusMessage = nil
                }
            }
        }
    }
}

// MARK: - Result Model
struct PlantRecognitionResult: Identifiable {
    let id = UUID()
    let plantName: String
    let confidence: Double
    let description: String
    let relatedTheory: String
}

// MARK: - Result View