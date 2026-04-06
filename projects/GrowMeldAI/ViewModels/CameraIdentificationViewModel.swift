import Foundation
import Combine

@MainActor
class CameraIdentificationViewModel: ObservableObject {
    @Published var isProcessing = false
}
