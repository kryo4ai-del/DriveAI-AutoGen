import SwiftUI

class TrafficSignRecognitionViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var recognitionResult: TrafficSignRecognitionResult?
    @Published var isAnalyzing: Bool = false
    @Published var showImagePicker: Bool = false

    private let service = TrafficSignRecognitionService()
    private let historyService = TrafficSignHistoryService()

    // MARK: - Image selection

    func selectImage(_ image: UIImage) {
        selectedImage = image
        recognitionResult = nil
        analyze(image)
    }

    func clearImage() {
        selectedImage = nil
        recognitionResult = nil
    }

    // MARK: - Analysis

    private func analyze(_ image: UIImage) {
        isAnalyzing = true
        service.recognize(image: image) { [weak self] result in
            self?.recognitionResult = result
            self?.isAnalyzing = false
            self?.historyService.save(from: result)
        }
    }
}
