import SwiftUI

struct CameraPreviewContainerView: View {
    @ObservedObject var viewModel: CameraPreviewViewModel
    let onCapture: () -> Void
    let onDismiss: () -> Void

    @State private var showQualityHint = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            CameraPreviewView(sessionManager: viewModel.sessionManager)

            VStack {
                CameraOnboardingHeaderView(examDaysRemaining: viewModel.examDaysRemaining)

                Spacer()

                guidanceSection
                qualityIndicator
                captureButton
            }
            .padding()

            closeButton
        }
        .sheet(isPresented: $showQualityHint) {
            QualityHintView(hint: viewModel.qualityHint)
        }
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
        Text(viewModel.guidanceMessage.primaryText)
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
                    viewModel.isCapturing ?
                        ProgressView() :
                        Image(systemName: "circle.fill")
                )
        }
        .disabled(viewModel.isCapturing)
    }
}