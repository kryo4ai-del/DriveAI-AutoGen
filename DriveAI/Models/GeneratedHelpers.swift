private func analyzeImage(_ image: UIImage) {
      imageAnalysisService.analyze(image: image) { [weak self] result in
          DispatchQueue.main.async {
              self?.analysisResult = result
          }
      }
  }

// ---

func analyze(image: UIImage, completion: @escaping (Result<AnalysisResult, Error>) -> Void) {
      DispatchQueue.global().async {
          // Simulate processing with potential error handling
          do {
              // Image recognition logic here
              let isRecognized = Bool.random()
              let result = AnalysisResult(isRecognized: isRecognized, description: isRecognized ? "Valid sign recognized." : "No sign recognized.")
              completion(.success(result))
          } catch {
              completion(.failure(error)) // Handle errors appropriately
          }
      }
  }