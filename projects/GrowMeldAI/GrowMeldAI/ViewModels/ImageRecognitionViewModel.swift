@MainActor
class ImageRecognitionViewModel: ObservableObject {
  @Published var isLoading: Bool = false
  @Published var result: IdentificationResult?
  @Published var error: ImageRecognitionError?
  
  func identifyFromCamera(_ image: UIImage) async
  func identifyFromLibrary(_ image: UIImage) async
  func clearResult()
}