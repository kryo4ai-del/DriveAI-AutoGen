import CoreML

class TrafficSignRecognizerInput: MLFeatureProvider {
    var image: CVPixelBuffer

    var featureNames: Set<String> {
        return ["image"]
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "image" {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }

    init(image: CVPixelBuffer) {
        self.image = image
    }
}