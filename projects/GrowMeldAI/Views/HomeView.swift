import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let lpVM = viewModel.learningPlanVM {
                        LearningPlanView(viewModel: lpVM)
                    }
                }
                .padding()
            }
        }
        .task {
            await viewModel.loadDashboard()
        }
    }
}