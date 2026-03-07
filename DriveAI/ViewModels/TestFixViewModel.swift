class TestFixViewModel {
       private let dataService: LocalDataServiceProtocol // Define a protocol for data service
       
       init(dataService: LocalDataServiceProtocol) {
           self.dataService = dataService
           loadQuestions()
       }
   }