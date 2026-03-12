import Foundation
import UIKit
import Combine

class RealQuestionTestViewModel: ObservableObject {

    // MARK: - Pipeline state

    enum PipelineState {
        case idle
        case running(String)
        case done
        case error(String)
    }

    @Published var state: PipelineState = .idle
    @Published var selectedImage: UIImage?

    // Pipeline results
    @Published var ocrText: String?
    @Published var parsedQuestion: String?
    @Published var detectedAnswers: [String] = []
    @Published var solverPrediction: String?
    @Published var solverExplanation: String?
    @Published var solverConfidence: Double = 0
    @Published var detectedCategory: String?
    @Published var categoryConfidence: Double = 0
    @Published var matchedKeywords: [String] = []

    // MARK: - Services

    private let ocrService = OCRRecognitionService(minimumImageSize: CGSize(width: 100, height: 100))
    private let categoryService = QuestionCategoryDetectionService()
    private let solverService = LLMQuestionSolverService()

    // MARK: - Run pipeline

    func runPipeline(image: UIImage) {
        selectedImage = image
        resetResults()
        state = .running("OCR Recognition...")

        ocrService.recognizeText(from: image) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let text):
                    self.ocrText = text.isEmpty ? "(no text detected)" : text
                    self.runParsing(text: text)
                case .failure(let error):
                    self.ocrText = "Error: \(error)"
                    self.state = .error("OCR failed: \(error)")
                }
            }
        }
    }

    // Answer prefix pattern: A) B. C: 1. 2) - or bullet
    private static let answerPrefixPattern = #"^(?:[A-Da-d][\)\.\:]|[1-4][\)\.]|[-•◦▪□☐✓✗]\s)"#

    // Standalone letter on its own line (e.g. "A" "B" "C" "D")
    private static let standaloneLetter = #"^[A-Da-d]$"#

    // UI noise fragments to filter out (timer, navigation, app chrome)
    private static let noisePatterns: [String] = [
        #"^\d{1,2}:\d{2}(:\d{2})?$"#,           // timer: 0:00:28, 14:56
        #"^Punkte:\s*\d+"#,                       // Punkte: 5
        #"^noch\s+\d+\s+Aufgaben"#,               // noch 25 Aufgaben
        #"^Frage:?\s*\d+"#,                        // Frage: 6, Frage 1:
        #"^Führerscheintest"#,                     // Führerscheintest header
        #"^\d{1,2}$"#,                             // standalone numbers (question grid)
    ]

    private static let noiseExactWords: Set<String> = [
        "Grundstoff", "Klasse B", "Klasse A", "Klasse C", "Klasse D",
        "freenet", "MOBILFUNK", "WhatsApp",
        "Weiter", "Abgabe", "Zurück", "Überspringen",
        "Bildfrage", "Theorieprüfung Simulation",
    ]

    private static func isNoise(_ line: String) -> Bool {
        if noiseExactWords.contains(line) { return true }
        for pattern in noisePatterns {
            if line.range(of: pattern, options: .regularExpression) != nil { return true }
        }
        return false
    }

    private func runParsing(text: String) {
        state = .running("Parsing question...")

        let lines = text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .filter { !Self.isNoise($0) }

        var questionLines: [String] = []
        var answers: [String] = []
        var pendingLetter: String? = nil

        for line in lines {
            let isAnswerPrefix = line.range(of: Self.answerPrefixPattern, options: .regularExpression) != nil
            let isStandalone = line.range(of: Self.standaloneLetter, options: .regularExpression) != nil

            if isStandalone {
                // Standalone letter (A/B/C/D) — wait for next line as answer text
                pendingLetter = line.uppercased()
                continue
            }

            if let letter = pendingLetter {
                // Previous line was a standalone letter — combine: "A) answer text"
                answers.append("\(letter)) \(line)")
                pendingLetter = nil
            } else if isAnswerPrefix {
                answers.append(line)
            } else if answers.isEmpty {
                questionLines.append(line)
            } else {
                // Multi-line answer: append to previous answer
                let lastIndex = answers.count - 1
                answers[lastIndex] += " " + line
            }
        }

        // Handle trailing standalone letter with no following text
        if let letter = pendingLetter {
            answers.append("\(letter))")
        }

        parsedQuestion = questionLines.isEmpty ? "(no question detected)" : questionLines.joined(separator: " ")
        detectedAnswers = answers

        runCategoryDetection(questionText: parsedQuestion ?? "", answers: answers)
        runSolver(questionText: parsedQuestion ?? "", answers: answers)
    }

    private func runCategoryDetection(questionText: String, answers: [String]) {
        state = .running("Detecting category...")

        let detection = categoryService.detectCategory(
            questionText: questionText,
            answers: answers
        )

        detectedCategory = detection.category.rawValue
        categoryConfidence = detection.confidence
        matchedKeywords = detection.matchedKeywords
    }

    private func runSolver(questionText: String, answers: [String]) {
        state = .running("Running solver...")

        let fullQuestion = answers.isEmpty
            ? questionText
            : questionText + "\n" + answers.joined(separator: "\n")

        solverService.solveQuestion(fullQuestion, answer: "") { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let answerResult):
                    self.solverPrediction = answerResult.predictedAnswer
                    self.solverExplanation = answerResult.explanation
                    self.solverConfidence = answerResult.confidence.score
                    self.state = .done
                case .failure:
                    self.solverPrediction = "(solver unavailable)"
                    self.solverExplanation = "LLM solver not connected (placeholder endpoint)"
                    self.solverConfidence = 0
                    self.state = .done
                }
            }
        }
    }

    func resetResults() {
        ocrText = nil
        parsedQuestion = nil
        detectedAnswers = []
        solverPrediction = nil
        solverExplanation = nil
        solverConfidence = 0
        detectedCategory = nil
        categoryConfidence = 0
        matchedKeywords = []
    }
}
