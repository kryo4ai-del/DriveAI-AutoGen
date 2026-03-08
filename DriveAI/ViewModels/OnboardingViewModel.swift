class OnboardingViewModel: ObservableObject {
       @Published var errorMessage: String?
       
       func handleError(_ error: Error) {
           // Handle error, setting an appropriate message
           self.errorMessage = error.localizedDescription
       }
   }