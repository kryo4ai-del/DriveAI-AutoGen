import Combine

@MainActor
final class SignRecognitionViewModel: ObservableObject {
    @Published var recognizedSign: RecognizedSign?
    @Published var isRecognizing = false
    @Published var error: RecognitionError?
    @Published var selectedReviewTiming: ReviewTiming = .tonight
    @Published var additionStatus: AdditionStatus = .idle
    
    let recognitionService: SignRecognitionService
    let learningQueueService: LearningQueueService
    
    enum AdditionStatus {
        case idle
        case adding
        case success
        case failed(String)
    }
    
    init(
        recognitionService: SignRecognitionService = .init(),
        learningQueueService: LearningQueueService
    ) {
        self.recognitionService = recognitionService
        self.learningQueueService = learningQueueService
    }
    
    /// Recognize a sign from captured image
    func recognizeSign(from image: UIImage) async {
        isRecognizing = true
        error = nil
        recognizedSign = nil
        
        let result = await recognitionService.recognizeSign(from: image)
        
        await MainActor.run {
            self.recognizedSign = result
            self.isRecognizing = false
            
            if result == nil {
                self.error = self.recognitionService.error
            }
        }
    }
    
    /// Add recognized sign to learning queue with selected timing
    func addToLearningQueue() async {
        guard let sign = recognizedSign else {
            error = .recognitionFailed("Kein Schild zum Hinzufügen ausgewählt")
            return
        }
        
        additionStatus = .adding
        error = nil
        
        let queuedSign = QueuedSign(
            sign: sign,
            addedDate: Date(),
            scheduledReviewDate: Date().addingTimeInterval(
                selectedReviewTiming.delayInSeconds
            ),
            reviewTiming: selectedReviewTiming
        )
        
        do {
            try await learningQueueService.addSign(queuedSign)
            
            await MainActor.run {
                self.additionStatus = .success
                self.recognizedSign = nil  // Clear for next recognition
                self.selectedReviewTiming = .tonight  // Reset to default
            }
        } catch {
            let errorMsg = error.localizedDescription
            await MainActor.run {
                self.additionStatus = .failed(errorMsg)
                self.error = .recognitionFailed(errorMsg)
            }
        }
    }
    
    /// Reset state for next recognition
    func reset() {
        recognizedSign = nil
        error = nil
        additionStatus = .idle
        selectedReviewTiming = .tonight
    }
}