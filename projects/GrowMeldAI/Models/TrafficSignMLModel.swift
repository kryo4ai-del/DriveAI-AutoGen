import CoreML
import Vision

class TrafficSignMLModel: TrafficSignMLModelProtocol {
    private var mlModel: MLModel?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            mlModel = try TrafficSignRecognizer(configuration: MLModelConfiguration()).model
        } catch {
            Logger().error("❌ Failed to load model: \(error.localizedDescription)")
        }
    }
    
    func predict(pixelBuffer: CVPixelBuffer) -> MLPrediction {
        guard let mlModel = mlModel else {
            return MLPrediction(labelId: "", confidence: 0, inferenceTimeMs: 0)
        }
        
        let startTime = Date()
        
        do {
            // ✅ Use auto-generated input class
            let input = TrafficSignRecognizerInput(image: pixelBuffer)
            let output = try mlModel.prediction(from: input) as! TrafficSignRecognizerOutput
            
            let elapsed = Int((Date().timeIntervalSince(startTime)) * 1000)
            
            return MLPrediction(
                labelId: output.classLabel,
                confidence: Float(output.classLabelProbs[output.classLabel] ?? 0),
                inferenceTimeMs: elapsed
            )
        } catch {
            Logger().error("❌ Inference failed: \(error.localizedDescription)")
            return MLPrediction(labelId: "", confidence: 0, inferenceTimeMs: Int((Date().timeIntervalSince(startTime)) * 1000))
        }
    }
    
    var isModelLoaded: Bool { mlModel != nil }
}