import UIKit
import Vision
enum OCRServiceError: Error {
       case imageUnavailable
       case recognitionFailed
   }
   
   func performOCR(on image: UIImage, completion: @escaping (Result<String, OCRServiceError>) -> Void) {
       guard let cgImage = image.cgImage else {
           completion(.failure(.imageUnavailable))
           return
       }
       
       let request = VNRecognizeTextRequest { request, error in
           if let error = error {
               print("Error during OCR: \(error)")
               completion(.failure(.recognitionFailed))
               return
           }
           
           guard let observations = request.results as? [VNRecognizedTextObservation] else {
               completion(.failure(.recognitionFailed))
               return
           }
           
           let recognizedTexts = observations.compactMap { observation in
               observation.topCandidates(1).first?.string
           }.joined(separator: " ")

           completion(.success(recognizedTexts))
       }
       
       request.recognitionLevel = .accurate
       let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
       
       do {
           try handler.perform([request])
       } catch {
           print("Error performing OCR: \(error)")
           completion(.failure(.recognitionFailed))
       }
   }