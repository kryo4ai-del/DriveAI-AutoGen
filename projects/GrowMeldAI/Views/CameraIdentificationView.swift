import SwiftUI

struct CameraIdentificationView: View {
    @StateObject var viewModel: CameraIdentificationViewModel
    @State var showErrorAlert = false

    var body: some View {
        ZStack {
        }
        .onChange(of: viewModel.recognitionState) { newState in
            if case .error(let message) = newState {
                showErrorAlert = true
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
        .alert("Erkennungsfehler", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if case .error(let message) = viewModel.recognitionState {
                Text(message)
                    .accessibilityLabel("Fehler")
                    .accessibilityValue(message)
            }
        }
    }
}

class CameraIdentificationViewModel: ObservableObject {
    enum RecognitionState {
        case idle
        case processing
        case success(String)
        case error(String)
    }

    @Published var recognitionState: RecognitionState = .idle
}