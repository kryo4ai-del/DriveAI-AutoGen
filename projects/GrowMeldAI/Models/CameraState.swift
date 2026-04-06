enum CameraState {
    case idle
    case capturing
    case processing
    case showingResult(SignRecognitionResult)
    case error(RecognitionError, retryAction: (() -> Void)?)
    
    var actionDescription: String {
        switch self {
        case .idle: return ""
        case .capturing: return "Capture in progress..."
        case .processing: return "Analyzing..."
        case .showingResult: return ""
        case .error(let err, _):
            switch err {
            case .lowConfidence:
                return "Try adjusting angle"
            case .preprocessingFailed:
                return "Retry with better lighting"
            case .inferenceFailed:
                return "Model error - retry later"
            case .offline:
                return "Offline - check connection"
            }
        }
    }
}

// In ViewModel:
private func handleCapture(_ image: UIImage) async {
    isProcessing = true
    cameraState = .processing
    
    do {
        let result = try await recognitionService.recognizeSign(from: image)
        
        if result.confidence >= ConfidenceThreshold.display {
            recognitionResult = result
            cameraState = .showingResult(result)
        } else {
            // ✅ Provide retry action
            cameraState = .error(
                .lowConfidence(confidence: result.confidence),
                retryAction: { [weak self] in
                    Task { await self?.handleCapture(image) }
                }
            )
        }
    } catch let error as RecognitionServiceError {
        // ✅ Provide context-specific retry
        cameraState = .error(error) { [weak self] in
            Task { await self?.handleCapture(image) }
        }
    } catch {
        cameraState = .error(.unknown)
    }
    
    isProcessing = false
}