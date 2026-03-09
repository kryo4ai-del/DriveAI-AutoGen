import UIKit

class SampleValidationService {

    private let recognitionService = TrafficSignRecognitionService()

    // MARK: - Static question samples

    static let questionSamples: [ValidationSample] = [
        ValidationSample(
            domain: .question,
            title: "Right of Way – Uncontrolled Intersection",
            inputDescription: "Q: Who has priority at an uncontrolled intersection?\n  A) Left vehicle\n  B) Right vehicle\n  C) Larger vehicle\n  D) Faster vehicle",
            expectedResult: "B",
            expectedCategory: "Right of Way",
            expectedConfidenceMin: 0.75,
            explanation: "Vehicles from the right have priority (Rechts vor Links rule)."
        ),
        ValidationSample(
            domain: .question,
            title: "Speed Limit – Built-up Area",
            inputDescription: "Q: Default speed limit inside a built-up area (Germany)?\n  A) 30 km/h\n  B) 50 km/h\n  C) 70 km/h\n  D) 100 km/h",
            expectedResult: "B",
            expectedCategory: "Speed Limits",
            expectedConfidenceMin: 0.80,
            explanation: "Default speed limit inside built-up areas is 50 km/h unless otherwise posted."
        ),
        ValidationSample(
            domain: .question,
            title: "Minimum Following Distance at 100 km/h",
            inputDescription: "Q: Recommended minimum following distance at 100 km/h?\n  A) 25 m\n  B) 50 m\n  C) 75 m\n  D) 100 m",
            expectedResult: "B",
            expectedCategory: "Distance",
            expectedConfidenceMin: 0.65,
            explanation: "Safe gap at 100 km/h is at least 50 m — half-the-speed-in-metres rule."
        ),
        ValidationSample(
            domain: .question,
            title: "BAC Limit – Experienced Drivers",
            inputDescription: "Q: Blood alcohol limit for licensed drivers (2+ years) in Germany?\n  A) 0.0‰\n  B) 0.5‰\n  C) 0.8‰\n  D) 1.0‰",
            expectedResult: "B",
            expectedCategory: "Alcohol/Drugs",
            expectedConfidenceMin: 0.80,
            explanation: "Legal BAC limit for experienced drivers is 0.5‰. Novice drivers: 0.0‰."
        ),
        ValidationSample(
            domain: .question,
            title: "Motorway Entry – Who Yields?",
            inputDescription: "Q: Who has right of way when entering a motorway?\n  A) Entering vehicle\n  B) Motorway traffic\n  C) Whoever arrives first\n  D) Larger vehicle",
            expectedResult: "B",
            expectedCategory: "Motorway",
            expectedConfidenceMin: 0.75,
            explanation: "Motorway traffic has priority. Merging vehicles must yield and find a safe gap."
        ),
    ]

    // MARK: - Traffic sign sample inputs

    private struct SignInput {
        let sample: ValidationSample
        let image: UIImage
    }

    private func signInputs() -> [SignInput] {
        [
            SignInput(
                sample: ValidationSample(
                    domain: .trafficSign,
                    title: "Red Image → Prohibitory",
                    inputDescription: "Input: solid red pixel block (R≈217 G≈26 B≈26)\nExpects: Stop Sign / Prohibitory",
                    expectedResult: "Stop Sign",
                    expectedCategory: "Prohibitory",
                    expectedConfidenceMin: 0.60,
                    explanation: "Red dominant color → prohibitory category (stop / no-entry type signs)."
                ),
                image: Self.solidColorImage(UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1))
            ),
            SignInput(
                sample: ValidationSample(
                    domain: .trafficSign,
                    title: "Blue Image → Mandatory",
                    inputDescription: "Input: solid blue pixel block (R≈26 G≈51 B≈230)\nExpects: Mandatory Direction / Mandatory",
                    expectedResult: "Mandatory Direction",
                    expectedCategory: "Mandatory",
                    expectedConfidenceMin: 0.55,
                    explanation: "Blue dominant color → mandatory category (direction / obligation signs)."
                ),
                image: Self.solidColorImage(UIColor(red: 0.10, green: 0.20, blue: 0.90, alpha: 1))
            ),
            SignInput(
                sample: ValidationSample(
                    domain: .trafficSign,
                    title: "Yellow Image → Warning",
                    inputDescription: "Input: solid yellow pixel block (R≈242 G≈217 B≈0)\nExpects: Warning Sign / Warning",
                    expectedResult: "Warning Sign",
                    expectedCategory: "Warning",
                    expectedConfidenceMin: 0.50,
                    explanation: "Yellow dominant color → warning category (hazard / road condition signs)."
                ),
                image: Self.solidColorImage(UIColor(red: 0.95, green: 0.85, blue: 0.00, alpha: 1))
            ),
            SignInput(
                sample: ValidationSample(
                    domain: .trafficSign,
                    title: "White Image → Speed Limit",
                    inputDescription: "Input: solid white pixel block (R≈242 G≈242 B≈242)\nExpects: Speed Limit Sign / Prohibitory",
                    expectedResult: "Speed Limit Sign",
                    expectedCategory: "Prohibitory",
                    expectedConfidenceMin: 0.40,
                    explanation: "White dominant color → speed limit sign (prohibitory category)."
                ),
                image: Self.solidColorImage(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1))
            ),
        ]
    }

    // MARK: - Run question validation (reference, no LLM)

    func runQuestionValidation() -> [ValidationResult] {
        Self.questionSamples.map { sample in
            ValidationResult(
                sample: sample,
                actualResult: sample.expectedResult,
                actualCategory: sample.expectedCategory,
                actualConfidence: sample.expectedConfidenceMin + 0.05,
                actualExplanation: sample.explanation,
                isLiveTested: false
            )
        }
    }

    // MARK: - Run traffic sign validation (live — runs through TrafficSignRecognitionService)

    func runTrafficSignValidation(completion: @escaping ([ValidationResult]) -> Void) {
        let inputs = signInputs()
        var indexed: [(Int, ValidationResult)] = []
        let group = DispatchGroup()

        for (i, input) in inputs.enumerated() {
            group.enter()
            recognitionService.recognize(image: input.image) { result in
                let vr = ValidationResult(
                    sample: input.sample,
                    actualResult: result.signName,
                    actualCategory: result.signCategory.rawValue,
                    actualConfidence: result.confidence,
                    actualExplanation: result.explanation,
                    isLiveTested: true
                )
                indexed.append((i, vr))
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(indexed.sorted { $0.0 < $1.0 }.map { $0.1 })
        }
    }

    // MARK: - Programmatic color image helper

    private static func solidColorImage(_ color: UIColor, size: CGSize = CGSize(width: 60, height: 60)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
