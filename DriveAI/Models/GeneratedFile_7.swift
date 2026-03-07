@State private var showErrorAlert = false
     @State private var errorMessage: String?

     // In loadProgress completion
     case .failure(let error):
         errorMessage = error.localizedDescription // Customize as needed
         showErrorAlert = true