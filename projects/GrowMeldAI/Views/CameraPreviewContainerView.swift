import SwiftUI
import AVFoundation

struct CameraPreviewContainerView: View {
    @ObservedObject var viewModel: CameraPreviewViewModel
    let onCapture: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            VStack {
                headerSection

                Spacer()

                guidanceSection
                qualityIndicator
                captureButton
            }
            .padding()

            closeButton
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Kamera")
                    .font(.headline)
                    .foregroundColor(.white)
                if viewModel.examDaysRemaining > 0 {
                    Text("Noch \(viewModel.examDaysRemaining) Tage bis zur Prüfung")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            Spacer()
        }
        .padding(.top, 16)
    }

    private var closeButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding(8)
        }
        .padding(.top, 16)
        .padding(.trailing, 16)
    }

    private var guidanceSection: some View {
        Text(viewModel.guidanceMessage)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
    }

    private var qualityIndicator: some View {
        HStack {
            Text("Qualität: \(viewModel.qualityPercentage)%")
            if viewModel.qualityPercentage < 70 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
            }
        }
        .font(.caption)
        .foregroundColor(.white)
    }

    private var captureButton: some View {
        Button(action: onCapture) {
            Circle()
                .fill(viewModel.isCapturing ? Color.gray : Color.white)
                .frame(width: 80, height: 80)
                .overlay(
                    Group {
                        if viewModel.isCapturing {
                            ProgressView()
                        } else {
                            Image(systemName: "circle.fill")
                        }
                    }
                )
        }
        .disabled(viewModel.isCapturing)
    }
}

class CameraPreviewViewModel: ObservableObject {
    @Published var examDaysRemaining: Int = 0
    @Published var guidanceMessage: String = ""
    @Published var qualityPercentage: Int = 100
    @Published var isCapturing: Bool = false
}