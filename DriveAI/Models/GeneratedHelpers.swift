private let minimumImageSize: CGSize = CGSize(width: 500, height: 500)

// ---

private func logError(_ error: String) {
         // Implement logging logic
     }

// ---

private let minimumImageSize: CGSize

     init(minimumImageSize: CGSize = CGSize(width: 500, height: 500)) {
         self.minimumImageSize = minimumImageSize
     }

// ---

private func logError(_ error: OCRRecognitionError) {
         // Implement a logging framework or send errors to a server
     }

// ---

let request = VNRecognizeTextRequest { [weak self] (request, error) in
         // handle result
     }

// ---

DispatchQueue.global(qos: .userInitiated).async {
         // Perform OCR recognition here

         DispatchQueue.main.async {
             // Update UI with recognized text
         }
     }