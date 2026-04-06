import SwiftUI

// MARK: - AppDelegate

final class AppDelegate: NSObject, ObservableObject {

    static let recognitionService: RecognitionServiceProtocol = RecognitionService()

    func applicationDidFinishLaunching() {
        // ✅ Load ML model asynchronously in background
        // Non-blocking, parallel to app UI initialization
        Task(priority: .userInitiated) {
            do {
                try await AppDelegate.recognitionService.loadModel()
                print("ML model loaded successfully")
            } catch {
                print("Failed to preload ML model: \(error)")
                // Fall back to on-demand loading
            }
        }
    }
}

// MARK: - RecognitionServiceProtocol

protocol RecognitionServiceProtocol: AnyObject {
    func loadModel() async throws
    func recognize(imageData: Data) async throws -> [RecognitionResult]
}

// MARK: - RecognitionResult

struct RecognitionResult: Identifiable, Codable {
    let id: UUID
    let label: String
    let confidence: Float

    init(id: UUID = UUID(), label: String, confidence: Float) {
        self.id = id
        self.label = label
        self.confidence = confidence
    }
}

// MARK: - RecognitionService

final class RecognitionService: RecognitionServiceProtocol {

    private var isModelLoaded: Bool = false

    init() {}

    func loadModel() async throws {
        guard !isModelLoaded else { return }
        // Simulate async model loading
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        isModelLoaded = true
        print("RecognitionService: model ready")
    }

    func recognize(imageData: Data) async throws -> [RecognitionResult] {
        guard isModelLoaded else {
            try await loadModel()
            return []
        }
        // Placeholder recognition logic
        return []
    }
}

// MARK: - CameraViewModel

@MainActor
final class CameraViewModel: ObservableObject {

    @Published var results: [RecognitionResult] = []
    @Published var isModelReady: Bool = false

    private let recognitionService: RecognitionServiceProtocol

    init(recognitionService: RecognitionServiceProtocol = AppDelegate.recognitionService) {
        self.recognitionService = recognitionService

        // Ensure model is ready when camera view appears
        Task(priority: .userInitiated) {
            do {
                try await recognitionService.loadModel()
                self.isModelReady = true
            } catch {
                print("CameraViewModel: failed to load model: \(error)")
            }
        }
    }

    func processFrame(imageData: Data) async {
        do {
            let recognitionResults = try await recognitionService.recognize(imageData: imageData)
            self.results = recognitionResults
        } catch {
            print("CameraViewModel: recognition failed: \(error)")
        }
    }
}