protocol DataServiceProtocol {
      func loadQuestions(completion: @escaping ([Question]) -> Void)
  }

  class DataService: DataServiceProtocol {
      // Existing implementation...
  }
  
  class TestFixViewModel: ObservableObject {
      private let dataService: DataServiceProtocol

      init(dataService: DataServiceProtocol = DataService()) {
          self.dataService = dataService
          fetchTestFixData()
      }
      // Remaining code...
  }