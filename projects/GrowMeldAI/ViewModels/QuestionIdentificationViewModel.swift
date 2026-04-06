@MainActor
final class QuestionIdentificationViewModel: ObservableObject {
    private var progressTimer: Timer?
    private var analysisTask: Task<Void, Never>?
    
    deinit {
        progressTimer?.invalidate()  // ✅ REQUIRED
        analysisTask?.cancel()        // ✅ REQUIRED
    }
    
    func analyzeImage(_ image: UIImage) async {
        // Always clean up previous timer
        progressTimer?.invalidate()
        analysisTask?.cancel()
        
        state = .analyzing
        analysisStartTime = Date()
        
        // Create timer with safety gates
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.elapsedTime = Date().timeIntervalSince(self.analysisStartTime ?? Date())
                
                // Auto-cleanup when analysis finishes
                if case .success = self.state {
                    self.progressTimer?.invalidate()
                    self.progressTimer = nil
                }
            }
        }
        
        // Wrap async work for cancellation support
        analysisTask = Task {
            let result = await identificationService.identifyQuestion(from: image)
            
            // ✅ ALWAYS invalidate on completion
            progressTimer?.invalidate()
            progressTimer = nil
            
            await updateState(from: result)
        }
    }
    
    func resetState() {
        state = .idle
        progressTimer?.invalidate()
        analysisTask?.cancel()
        progressTimer = nil
        analysisTask = nil
    }
}