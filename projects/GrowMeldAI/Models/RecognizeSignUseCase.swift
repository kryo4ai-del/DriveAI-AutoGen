// Features/KIIdentifikation/Domain/UseCases/RecognizeSignUseCase.swift

import Combine

protocol RecognizeSignUseCase {
    func execute(
        pixelBuffer: CVPixelBuffer
    ) -> AnyPublisher<TrafficSignRecognition, RecognitionError>
}

class DefaultRecognizeSignUseCase: RecognizeSignUseCase {
    private let mlModel: TrafficSignMLModelProtocol
    private let repository: TrafficSignRepository
    
    init(
        mlModel: TrafficSignMLModelProtocol,
        repository: TrafficSignRepository
    ) {
        self.mlModel = mlModel
        self.repository = repository
    }
    
    func execute(
        pixelBuffer: CVPixelBuffer
    ) -> AnyPublisher<TrafficSignRecognition, RecognitionError> {
        let prediction = mlModel.predict(pixelBuffer: pixelBuffer)
        
        return repository.fetchSign(by: prediction.labelId)
            .map { sign in
                TrafficSignRecognition(
                    sign: sign,
                    confidence: prediction.confidence,
                    recognitionTimeMs: prediction.inferenceTimeMs,
                    cameraCondition: .normal
                )
            }
            .mapError { _ in RecognitionError.mlModelError("Sign not found") }
            .eraseToAnyPublisher()
    }
}

// Features/KIIdentifikation/Presentation/ViewModels/CameraIdentificationViewModel.swift
