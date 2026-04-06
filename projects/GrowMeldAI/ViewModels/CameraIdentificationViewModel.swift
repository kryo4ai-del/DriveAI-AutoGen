import Foundation
import SwiftUI
import Combine
import UIKit

enum RecognitionState {
    case idle
    case scanning
    case recognized(recognition: TrafficSignRecognition?)
    case failed(Error)
}

struct TrafficSignRecognition {
    let sign: TrafficSign
    let confidence: Float
}

struct TrafficSign {
    let germanName: String
}

@MainActor
class CameraIdentificationViewModel: ObservableObject {
    @Published var recognitionState: RecognitionState = .idle

    private var currentRecognition: TrafficSignRecognition? = nil

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