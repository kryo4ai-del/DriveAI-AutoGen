// MARK: - OCRRecognitionProtocol

protocol OCRRecognitionProtocol {
    func recognizeText(from image: UIImage, completion: @escaping (Result<String, OCRRecognitionError>) -> Void)
}

// MARK: - OCRRecognitionError

enum OCRRecognitionError: Error {
    case imageTooSmall
    case recognitionFailed(reason: String)
    case unknownError
}

// MARK: - OCRRecognitionService

import Vision
import UIKit

final class OCRRecognitionService: OCRRecognitionProtocol {
    
    func recognizeText(from image: UIImage, completion: @escaping (Result<String, OCRRecognitionError>) -> Void) {
        // Ensure the image has a minimum size for OCR processing
        guard image.size.width >= 100, image.size.height >= 100 else {
            completion(.failure(.imageTooSmall))
            return
        }
        
        // Check if the UIImage can be converted to CGImage
        guard let cgImage = image.cgImage else {
            completion(.failure(.unknownError))
            return
        }

        // Create a request for text recognition
        let request = VNRecognizeTextRequest { (request, error) in
            // Handle potential errors from the recognition
            if let error = error {
                completion(.failure(.recognitionFailed(reason: error.localizedDescription)))
                print("OCR Recognition Error: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(.recognitionFailed(reason: "No recognizable text found.")))
                return
            }

            // Extract recognized text
            let recognizedTexts = observations.compactMap { $0.topCandidates(1).first?.string }
            completion(.success(recognizedTexts.joined(separator: " ")))
        }
        
        request.recognitionLevel = .accurate
        
        // Perform OCR processing in a background thread for responsiveness
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError))
                }
            }
        }
    }
}