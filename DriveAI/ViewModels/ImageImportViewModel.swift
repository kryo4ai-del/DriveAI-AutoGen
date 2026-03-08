import SwiftUI
import Combine

class ImageImportViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var analysisResult: AnalysisResult?
    @Published var errorMessage: String? // Added error message publisher
    private var cancellables = Set<AnyCancellable>()
    
    private let imageAnalysisService = ImageAnalysisService()
    
    func importImage(_ image: UIImage) {
        self.selectedImage = image
        analyzeImage(image)
    }
    
    private func analyzeImage(_ image: UIImage) {
        imageAnalysisService.analyze(image: image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let analysisResult):
                    self?.analysisResult = analysisResult
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.analysisResult = nil
                    self?.errorMessage = error.localizedDescription // Display error
                }
            }
        }
    }
}