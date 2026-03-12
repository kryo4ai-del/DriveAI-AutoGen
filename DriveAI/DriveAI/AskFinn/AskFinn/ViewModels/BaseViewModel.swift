import Combine

  class BaseViewModel: ObservableObject {
      @Published var errorMessage: String?
  }