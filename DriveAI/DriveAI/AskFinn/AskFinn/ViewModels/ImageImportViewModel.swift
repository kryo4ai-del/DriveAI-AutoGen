import SwiftUI
import Combine
import UIKit

class ImageImportViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var analysisResult: AnalysisResult?
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    private let imageAnalysisService = ImageAnalysisService(database: [])

    func importImage(_ image: UIImage) {
        self.selectedImage = image
        analyzeImage(image)
    }

    private func analyzeImage(_ image: UIImage) {
        let result = imageAnalysisService.analyzeImage(image)
        if let sign = result {
            self.analysisResult = AnalysisResult(
                question: "Traffic sign analysis",
                userAnswer: sign.name,
                correctAnswer: sign.name
            )
            self.errorMessage = nil
        } else {
            self.analysisResult = nil
            self.errorMessage = "Could not analyze the image."
        }
    }
}
