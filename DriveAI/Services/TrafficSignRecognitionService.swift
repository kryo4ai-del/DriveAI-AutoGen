import UIKit

/// Prototype traffic sign recognition service.
/// Architecture is designed for real vision integration — swap `classify(_:)` to call
/// a Vision/CoreML model or remote API without changing any callers.
class TrafficSignRecognitionService {

    // MARK: - Public API

    /// Classify an image and return a recognition result asynchronously.
    func recognize(image: UIImage, completion: @escaping (TrafficSignRecognitionResult) -> Void) {
        // Future: replace body with Vision / CoreML / LLM vision call.
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.classify(image)
            DispatchQueue.main.async { completion(result) }
        }
    }

    // MARK: - Classification (mock / rule-based prototype)

    private func classify(_ image: UIImage) -> TrafficSignRecognitionResult {
        // Prototype: use image color distribution as a lightweight heuristic.
        // This gives plausible variation without requiring a real model.
        // Replace with Vision / CoreML in production.

        let candidate = colorBasedCandidate(for: image)

        return TrafficSignRecognitionResult(
            signName: candidate.name,
            signCategory: candidate.category,
            explanation: candidate.explanation,
            confidence: candidate.confidence,
            imageData: compressImage(image)
        )
    }

    // MARK: - Color heuristic

    private func colorBasedCandidate(for image: UIImage) -> SignCandidate {
        let dominantColor = approximateDominantColor(image)

        switch dominantColor {
        case .red:
            return SignCandidate(
                name: "Stop Sign",
                category: .prohibitory,
                explanation: "A red octagonal sign requiring all vehicles to come to a complete stop before proceeding.",
                confidence: 0.72
            )
        case .blue:
            return SignCandidate(
                name: "Mandatory Direction",
                category: .mandatory,
                explanation: "A blue circular sign indicating a mandatory direction or action that drivers must follow.",
                confidence: 0.68
            )
        case .yellow:
            return SignCandidate(
                name: "Warning Sign",
                category: .warning,
                explanation: "A yellow diamond-shaped sign alerting drivers to a potential hazard or change in road conditions ahead.",
                confidence: 0.65
            )
        case .white:
            return SignCandidate(
                name: "Speed Limit Sign",
                category: .prohibitory,
                explanation: "A white circular sign with a red border indicating the maximum permitted speed in km/h.",
                confidence: 0.60
            )
        default:
            return SignCandidate(
                name: "Informational Sign",
                category: .informational,
                explanation: "An informational road sign providing guidance, directions, or general information to drivers.",
                confidence: 0.45
            )
        }
    }

    // MARK: - Dominant color detection

    private enum DominantColor { case red, blue, yellow, white, other }

    private func approximateDominantColor(_ image: UIImage) -> DominantColor {
        guard let cgImage = image.cgImage else { return .other }

        // Sample a 10×10 region at image center for speed
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: size))

        guard let context = UIGraphicsGetCurrentContext(),
              let pixelData = context.data else { return .other }

        let data = pixelData.bindMemory(to: UInt8.self, capacity: 400)

        var r: Float = 0, g: Float = 0, b: Float = 0
        let count = Float(100)
        for i in 0..<100 {
            let offset = i * 4
            r += Float(data[offset])
            g += Float(data[offset + 1])
            b += Float(data[offset + 2])
        }
        r /= count; g /= count; b /= count

        if r > 150 && r > g * 1.5 && r > b * 1.5 { return .red }
        if b > 150 && b > r * 1.4 && b > g * 0.9 { return .blue }
        if r > 180 && g > 150 && b < 80           { return .yellow }
        if r > 200 && g > 200 && b > 200           { return .white }
        return .other
    }

    // MARK: - Image compression (shared utility)

    func compressImage(_ image: UIImage) -> Data? {
        let maxDimension: CGFloat = 300
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let scaled = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return scaled.jpegData(compressionQuality: 0.4)
    }
}

// MARK: - Internal candidate type

private struct SignCandidate {
    let name: String
    let category: TrafficSignCategory
    let explanation: String
    let confidence: Double
}
