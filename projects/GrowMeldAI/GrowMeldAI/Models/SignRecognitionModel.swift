// ❌ PROBLEM: When is the 50-150MB CoreML model loaded?
// Current code doesn't clarify:

class SignRecognitionModel {
    func loadModel() async throws { ... }
    
    // ← Called from where? App launch? First camera view? 
    // No ownership/timing documented.
}