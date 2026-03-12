import SwiftUI

class TrafficSignRecognitionViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var recognitionResult: TrafficSignRecognitionResult?
    @Published var isAnalyzing: Bool = false
    @Published var showImagePicker: Bool = false

    // Learning mode state
    @Published var currentMode: TrafficSignLearningMode = .assist
    @Published var meaningOptions: [TrafficSignMeaningOption] = []
    @Published var selectedOptionId: UUID?
    @Published var userSubmitted: Bool = false
    @Published var isCorrect: Bool?

    var selectedOption: TrafficSignMeaningOption? {
        meaningOptions.first { $0.id == selectedOptionId }
    }

    private let service = TrafficSignRecognitionService()
    private let historyService = TrafficSignHistoryService()

    // MARK: - Mode

    func setMode(_ mode: TrafficSignLearningMode) {
        currentMode = mode
        resetLearningState()
    }

    // MARK: - Image selection

    func selectImage(_ image: UIImage) {
        selectedImage = image
        recognitionResult = nil
        resetLearningState()
        analyze(image)
    }

    func clearImage() {
        selectedImage = nil
        recognitionResult = nil
        resetLearningState()
    }

    // MARK: - Learning mode interaction

    func selectOption(_ id: UUID) {
        guard !userSubmitted else { return }
        selectedOptionId = id
    }

    func submitAnswer() {
        guard let option = selectedOption, let result = recognitionResult else { return }
        userSubmitted = true
        isCorrect = option.isCorrect
        saveHistory(result: result, selectedMeaning: option.title, isCorrect: option.isCorrect)
    }

    // MARK: - Analysis

    private func analyze(_ image: UIImage) {
        isAnalyzing = true
        service.recognize(image: image) { [weak self] result in
            guard let self else { return }
            self.recognitionResult = result
            self.isAnalyzing = false

            switch self.currentMode {
            case .assist:
                self.historyService.save(from: result)
            case .learning:
                self.meaningOptions = self.service.generateMeaningOptions(for: result)
            }
        }
    }

    // MARK: - History

    private func saveHistory(result: TrafficSignRecognitionResult,
                             selectedMeaning: String,
                             isCorrect: Bool) {
        let entry = TrafficSignHistoryEntry(
            from: result,
            userSelectedMeaning: selectedMeaning,
            userAnswerCorrect: isCorrect
        )
        historyService.save(entry)
    }

    // MARK: - Reset

    private func resetLearningState() {
        meaningOptions = []
        selectedOptionId = nil
        userSubmitted = false
        isCorrect = nil
    }
}
