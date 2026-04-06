// Features/Home/ViewModels/HomeViewModel+Preview.swift
#if DEBUG
extension HomeViewModel {
    static let preview = HomeViewModel(
        dataService: MockLocalDataService()
    )
    
    convenience init(dataService: LocalDataService = MockLocalDataService()) {
        self.init(dataService: dataService)
    }
}
#endif

// Use in previews
#Preview {
    HomeScreen()
        .environmentObject(HomeViewModel.preview)
}