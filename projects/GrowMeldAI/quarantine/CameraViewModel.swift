@MainActor
class CameraViewModel: ObservableObject {
    @Published var cameraState: CameraState = .idle
    @Published var recognitionResult: SignRecognitionResult?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    enum CameraState {
        case idle
        case capturing
        case processing
        case showingResult
        case error(String)
    }
    
    private let recognitionService: RecognitionServiceProtocol
    private let analyticsService: AnalyticsService
    
    init(
        recognitionService: RecognitionServiceProtocol,
        analyticsService: AnalyticsService
    ) {
        self.recognitionService = recognitionService
        self.analyticsService = analyticsService
    }
    
    func captureImage(_ image: UIImage) {
        Task {
            await handleCapture(image)
        }
    }
    
    private func handleCapture(_ image: UIImage) async {
        isProcessing = true
        cameraState = .processing
        analyticsService.logEvent("camera_capture_started")
        
        do {
            let result = try await recognitionService.recognizeSign(from: image)
            
            // Confidence check
            if result.confidence >= 0.75 {
                recognitionResult = result
                cameraState = .showingResult
                analyticsService.logEvent("sign_recognized", parameters: [
                    "sign_id": result.signID,
                    "confidence": String(result.confidence),
                    "elapsed_time": String(result.elapsedTime)
                ])
            } else {
                cameraState = .error("Erkennungssicherheit zu niedrig")
                analyticsService.logEvent("recognition_low_confidence", parameters: [
                    "confidence": String(result.confidence)
                ])
            }
        } catch {
            let errorMsg = (error as? LocalizedError)?.errorDescription ?? "Unbekannter Fehler"
            cameraState = .error(errorMsg)
            errorMessage = errorMsg
            analyticsService.logEvent("recognition_error", parameters: [
                "error": errorMsg
            ])
        }
        
        isProcessing = false
    }
    
    func dismissResult() {
        recognitionResult = nil
        cameraState = .idle
    }
}