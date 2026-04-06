// PlantIdentificationService.swift
import Foundation
import CoreML
import Vision
import Combine

enum PlantIdentificationError: Error {
    case cameraUnavailable
    case modelLoadFailed
    case predictionFailed
    case permissionDenied
}

protocol PlantIdentificationServiceProtocol {
    func identifyPlant(from image: UIImage) async throws -> Plant
}

final class PlantIdentificationService: PlantIdentificationServiceProtocol {
    private let model: VNCoreMLModel
    private let confidenceThreshold: Double = 0.5

    init() {
        guard let mlModel = try? PlantClassifier(configuration: MLModelConfiguration()).model else {
            fatalError("Failed to load Core ML model")
        }
        guard let vnModel = try? VNCoreMLModel(for: mlModel) else {
            fatalError("Failed to create Vision model")
        }
        self.model = vnModel
    }

    func identifyPlant(from image: UIImage) async throws -> Plant {
        guard let cgImage = image.cgImage else {
            throw PlantIdentificationError.predictionFailed
        }

        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                throw PlantIdentificationError.predictionFailed
            }

            if topResult.confidence >= confidenceThreshold {
                return Plant(
                    name: topResult.identifier,
                    scientificName: "Unknown", // In real app, map to scientific name
                    description: "A common plant species.", // In real app, fetch from database
                    confidence: Double(topResult.confidence)
                )
            } else {
                throw PlantIdentificationError.predictionFailed
            }
        } catch {
            throw PlantIdentificationError.predictionFailed
        }
    }
}