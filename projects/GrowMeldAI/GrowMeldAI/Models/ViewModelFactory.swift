import SwiftUI

// Create a factory for ViewModels
struct ViewModelFactory {
    private let dataService: LocalDataServiceProtocol
    private let userDataManager: UserDataManager
    
    init(
        dataService: LocalDataServiceProtocol = LocalDataService(),
        userDataManager: UserDataManager = .shared
    ) {
        self.dataService = dataService
        self.userDataManager = userDataManager
    }
    
    func makeQuestionViewModel() -> GrowMeldQuestionViewModel {
        GrowMeldQuestionViewModel(dataService: dataService, userDataManager: userDataManager)
    }
}

// Renamed to avoid ambiguity with any system or other module types
typealias GrowMeldQuestionViewModel = QuestionViewModel