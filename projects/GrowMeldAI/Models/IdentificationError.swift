// Services/IdentificationService.swift
import Foundation
import Vision
import CoreML
import UIKit

enum IdentificationError: Error, LocalizedError {
    case modelLoadFailure
    case imageProcessingFailure
    case timeout
    case noResults
    case invalidInput
    case cameraAccessDenied
    case modelNotFound

    var errorDescription: String? {
        switch self {
        case .modelLoadFailure: return "AI-Modell konnte nicht geladen werden"
        case .imageProcessingFailure: return "Bildverarbeitung fehlgeschlagen"
        case .timeout: return "Identifikation dauerte länger als 3 Sekunden"
        case .noResults: return "Keine Ergebnisse erkannt"
        case .invalidInput: return "Ungültiges Eingabebild"
        case .cameraAccessDenied: return "Kamera-Zugriff verweigert"
        case .modelNotFound: return "AI-Modell nicht gefunden"
        }
    }
}

final class IdentificationService {
    private let model: VNCoreMLModel
    private let timeout: TimeInterval = 3.0
    private let confidenceThreshold: Double = 0.7

    init?(modelName: String = "TrafficSignClassifier") {
        guard let mlModel = try? MLModel(contentsOf: TrafficSignClassifier.urlOfModelInThisBundle),
              let vnModel = try? VNCoreMLModel(for: mlModel) else {
            return nil
        }
        self.model = vnModel
    }

    func identify(image: UIImage) async throws -> IdentificationResult {
        guard let cgImage = image.cgImage else {
            throw IdentificationError.invalidInput
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                throw error
            }
        }

        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            guard let results = request.results as? [VNClassificationObservation],
                  let firstResult = results.first else {
                throw IdentificationError.noResults
            }

            if firstResult.confidence < Float(confidenceThreshold) {
                throw IdentificationError.noResults
            }

            return IdentificationResult(
                identifiedObject: firstResult.identifier,
                confidence: Double(firstResult.confidence),
                boundingBox: nil,
                timestamp: Date()
            )
        } catch {
            throw error
        }
    }
}