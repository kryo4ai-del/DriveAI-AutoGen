// Features/KIIdentifikation/Infrastructure/Performance/RecognitionPerformanceMonitor.swift
import os.log

class RecognitionPerformanceMonitor {
    private let logger = Logger(subsystem: "com.driveai.ki-identifikation", category: "performance")
    private var inferenceTimings: [Int] = []
    private var confidences: [Float] = []
    private let maxSamples = 100
    
    func recordInference(timeMs: Int, confidence: Float) {
        inferenceTimings.append(timeMs)
        confidences.append(confidence)
        
        if inferenceTimings.count > maxSamples {
            inferenceTimings.removeFirst()
            confidences.removeFirst()
        }
        
        let avgTime = averageInferenceTime()
        logger.debug("Inference: \(timeMs)ms | Avg: \(avgTime)ms | Confidence: \(confidence)")
    }
    
    func averageInferenceTime() -> Int {
        guard !inferenceTimings.isEmpty else { return 0 }
        return inferenceTimings.reduce(0, +) / inferenceTimings.count
    }
    
    func averageConfidence() -> Float {
        guard !confidences.isEmpty else { return 0 }
        return confidences.reduce(0, +) / Float(confidences.count)
    }
    
    func isUnder3Seconds() -> Bool {
        averageInferenceTime() < 3000
    }
    
    func getStatistics() -> PerformanceStatistics {
        return PerformanceStatistics(
            averageInferenceTimeMs: averageInferenceTime(),
            averageConfidence: averageConfidence(),
            totalInferences: inferenceTimings.count,
            minTimeMs: inferenceTimings.min() ?? 0,
            maxTimeMs: inferenceTimings.max() ?? 0
        )
    }
}

struct PerformanceStatistics {
    let averageInferenceTimeMs: Int
    let averageConfidence: Float
    let totalInferences: Int
    let minTimeMs: Int
    let maxTimeMs: Int
}