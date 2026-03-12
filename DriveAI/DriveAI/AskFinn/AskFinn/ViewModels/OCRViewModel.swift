import SwiftUI
import UIKit
import Combine

final class OCRViewModel: ObservableObject {
    private let ocrService: OCRRecognitionServiceProtocol
    @Published var recognizedText: String = ""

    init(ocrService: OCRRecognitionServiceProtocol = OCRRecognitionService()) {
        self.ocrService = ocrService
    }

    func processImage(image: UIImage) {
        ocrService.recognizeText(from: image) { [weak self] result in
            switch result {
            case .success(let text):
                DispatchQueue.main.async {
                    self?.recognizedText = text
                }
            case .failure(let error):
                print("Error recognizing text: \(error)")
            }
        }
    }
}