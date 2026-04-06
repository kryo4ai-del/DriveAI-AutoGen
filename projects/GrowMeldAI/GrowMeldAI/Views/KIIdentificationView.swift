// Views/KIIdentificationView.swift
import SwiftUI

struct KIIdentificationView: View {
    @StateObject private var viewModel = KIIdentificationViewModel()
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    var body: some View {
        VStack(spacing: 20) {
            headerView

            if viewModel.identificationState == .loading {
                ProgressView("Identifiziere Verkehrszeichen...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
            } else {
                cameraCaptureView
            }

            feedbackView
                .padding(.top, 20)

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .navigationTitle("KI-Identifikation")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                Task {
                    await viewModel.identify(image: image)
                }
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Schnell. Präzise. Prüfungsbereit.")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)

            Text("Trainiere dein Auge, um Verkehrszeichen in unter 3 Sekunden zu erkennen")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var cameraCaptureView: some View {
        Group {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
            } else {
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    Text("Foto aufnehmen")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var feedbackView: some View {
        Group {
            switch viewModel.identificationState {
            case .success(let result):
                successFeedback(result: result)
            case .error(let error):
                errorFeedback(error: error)
            case .timeout:
                timeoutFeedback
            default:
                EmptyView()
            }
        }
    }

    private func successFeedback(result: IdentificationResult) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)

            Text("Erkannt: \(result.identifiedObject)")
                .font(.title3)
                .fontWeight(.semibold)

            ProgressView(value: result.confidence, total: 1.0)
                .tint(.green)

            Text("Sicherheit: \(Int(result.confidence * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .transition(.opacity.combined(with: .scale))
    }

    private func errorFeedback(error: IdentificationError) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text(error.errorDescription ?? "Unbekannter Fehler")
                .font(.headline)
                .multilineTextAlignment(.center)

            Button("Erneut versuchen") {
                viewModel.reset()
            }
            .buttonStyle(.bordered)
        }
        .transition(.opacity.combined(with: .scale))
    }

    private var timeoutFeedback: some View {
        VStack(spacing: 12) {
            Image(systemName: "timer")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Zeit abgelaufen")
                .font(.headline)

            Text("Versuche es mit einem besseren Foto")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Neues Foto") {
                viewModel.reset()
                selectedImage = nil
            }
            .buttonStyle(.borderedProminent)
        }
        .transition(.opacity.combined(with: .scale))
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let image: Any
    let sourceType: Any

    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}