enum LoadError: Error {
         case dataFetchFailed
     }

     func loadProgress(completion: @escaping (Result<Float, LoadError>) -> Void) {
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             let success = true // Simulate success or failure
             if success {
                 self.progress = 75.0 // Placeholder value
                 completion(.success(self.progress))
             } else {
                 completion(.failure(.dataFetchFailed))
             }
         }
     }