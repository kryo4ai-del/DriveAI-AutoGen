struct TrafficSignRecognition {
      let signId: String
      let germanName: String
      let confidence: Float
      let recognitionTimeMs: Int
      let relatedQuestions: [Question]
  }
  
  struct RecognitionResult {
      let sign: TrafficSignRecognition?
      let timestamp: Date
      let cameraCondition: CameraCondition
      let isFinal: Bool
  }