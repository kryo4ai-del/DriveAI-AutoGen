// Models/PlantIdentity.swift
struct PlantIdentity: Identifiable, Codable {
    let id: UUID
    let germanName: String
    let scientificName: String
    let confidence: Float
    let description: String
    let imageURL: URL?
    let recognizedAt: Date
    
    var confidencePercentage: Int {
        Int(confidence * 100)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, germanName, scientificName, confidence, description, imageURL, recognizedAt
    }
}

// Models/CameraState.swift

// Models/RecognitionResult.swift
struct RecognitionResult: Codable {
    let plant: PlantIdentity
    let metadata: RecognitionMetadata
}

struct RecognitionMetadata: Codable {
    let processingTimeMs: Int
    let frameSize: String
    let modelVersion: String
}