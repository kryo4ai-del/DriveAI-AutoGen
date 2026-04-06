// Features/KIIdentifikation/Infrastructure/MLModels/TrafficSignMLModel.swift

import CoreML
import Vision
import os.log

protocol TrafficSignMLModelProtocol {
    func predict(pixelBuffer: CVPixelBuffer) -> MLPrediction
    var isModelLoaded: Bool { get }
}

enum MLError: LocalizedError {
    case invalidOutput
    var errorDescription: String? { "Invalid ML model output" }
}