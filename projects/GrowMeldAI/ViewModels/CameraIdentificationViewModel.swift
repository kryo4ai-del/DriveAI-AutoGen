import Foundation
import SwiftUI
import Combine
import UIKit

enum RecognitionState {
    case idle
    case scanning
    case recognized(recognition: PlantRecognition?)
    case failed(Error)
}

struct PlantRecognition {
    let sign: PlantSign
    let confidence: Float
}

struct PlantSign {
    let germanName: String
}

@MainActor
class CameraIdentificationViewModel: ObservableObject {
    @Published var recognitionState: RecognitionState = .idle

    private var currentRecognition: PlantRecognition?
    private var confidenceHistory: [Float] = []
    private let smoothingWindowSize = 5

    func startScanning() {
        recognitionState = .scanning
        confidenceHistory = []
    }

    func stopScanning() {
        recognitionState = .idle
        confidenceHistory = []
        currentRecognition = nil
    }

    func processConfidence(_ confidence: Float, recognition: PlantRecognition?) {
        currentRecognition = recognition
        confidenceHistory.append(confidence)
        if confidenceHistory.count > smoothingWindowSize {
            confidenceHistory.removeFirst()
        }
        let smoothed = confidenceHistory.reduce(0, +) / Float(confidenceHistory.count)
        updateRecognitionState(smoothed)
    }

    private func updateRecognitionState(_ smoothedConfidence: Float) {
        guard case .scanning = recognitionState else { return }

        if smoothedConfidence > 0.80 {
            let recognition = currentRecognition
            recognitionState = .recognized(recognition: recognition)

            UIAccessibility.post(
                notification: .announcement,
                argument: "Zeichen erkannt: \(recognition?.sign.germanName ?? "Unbekannt"). Sicherheit \(Int(smoothedConfidence * 100))%"
            )

            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
}