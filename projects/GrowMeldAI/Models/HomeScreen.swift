struct HomeScreen: View {
    @StateObject var dataService = LocalDataService.shared
    
    var body: some View {
        switch dataService.loadingState {
        case .loading:
            ProgressView()
        case .success:
            CategoriesView()
        case .failure(let message):
            ErrorView(message: message, retryAction: {
                Task { await dataService.reloadQuestions() }
            })
        case .idle:
            EmptyView()
        }
    }
}