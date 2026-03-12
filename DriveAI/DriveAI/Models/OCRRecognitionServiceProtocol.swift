import Foundation
import UIKit
import Vision

protocol OCRRecognitionServiceProtocol {
    func recognizeText(from image: UIImage, completion: @escaping (Result<String, OCRRecognitionError>) -> Void)
}

enum OCRRecognitionError: Error {
    case imageTooSmall
    case emptyImage
    case recognitionFailed(reason: String)
    case unknown
}

final class OCRRecognitionService: OCRRecognitionServiceProtocol {
    
    private let minimumImageSize: CGSize

    init(minimumImageSize: CGSize = CGSize(width: 500, height: 500)) {
        self.minimumImageSize = minimumImageSize
    }

    func recognizeText(from image: UIImage, completion: @escaping (Result<String, OCRRecognitionError>) -> Void) {
        
        guard image.size.width >= minimumImageSize.width,
              image.size.height >= minimumImageSize.height else {
            completion(.failure(.imageTooSmall))
            return
        }
        
        guard let cgImage = image.cgImage else {
            completion(.failure(.recognitionFailed(reason: "Failed to convert UIImage to CGImage.")))
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                self.logError(.unknown)
                completion(.failure(.unknown))
            }
        }
    }

    private func logError(_ error: OCRRecognitionError) {
        // Implement a logging mechanism for production
        print("OCR Error: \(error)")
    }
}