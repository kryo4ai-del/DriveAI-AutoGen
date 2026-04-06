struct ExamCenterFinderView: View {
    @StateObject private var viewModel: ExamCenterFinderViewModel
    
    var body: some View {
        List(viewModel.searchResults) { center in
            NavigationLink(destination: ExamCenterDetailView(center)) {
                ExamCenterRow(center)
            }
        }
        .onAppear { viewModel.loadAllCenters() }
    }
}