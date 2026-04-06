// ❌ PROBLEM: State mutated from multiple threads
@Published var state: CameraState = .idle

private func processPhoto(...) async {
    await MainActor.run {
        self.state = .processing  // ← Fine
    }
}

// But in video output delegate:
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(...) {
        // Background thread
        state = .idle  // ← WRONG: direct mutation off main thread
    }
}