import Foundation
import UIKit
import Vision

final class OCRRecognitionService: OCRRecognitionServiceProtocol {
    
    private let minimumImageSize: CGSize

    init(minimumImageSize: CGSize = CGSize(width: 500, height: 500)) {
        self.minimumImageSize = minimumImageSize
    }

    func recognizeText(from image: UIImage, completion: @escaping (Result<String, OCRRecognitionError>) -> Void) {
        
        // Ensure the image is not too small
        guard image.size.width >= minimumImageSize.width,
              image.size.height >= minimumImageSize.height else {
            completion(.failure(.imageTooSmall))
            return
        }
        
        // Convert UIImage to CGImage
        guard let cgImage = image.cgImage else {
            completion(.failure(.recognitionFailed(reason: "Failed to get CGImage from UIImage.")))
            return
        }

        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            if let error = error {
                self?.logError(.recognitionFailed(reason: error.localizedDescription))
                completion(.failure(.recognitionFailed(reason: error.localizedDescription)))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                completion(.success(""))
                return
            }

            let recognizedTexts = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            completion(.success(recognizedTexts))
        }
        
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                self.logError(.unknown) // Log unknown error
                completion(.failure(.unknown))
            }
        }
    }

    private func logError(_ error: OCRRecognitionError) {
        // Implement a logging mechanism as necessary, e.g., analytics, logging service
        print("OCR Error: \(error)")
    }
}