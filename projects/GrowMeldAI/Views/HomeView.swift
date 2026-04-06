import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var learningPlanVM: LearningPlanViewModel? = nil

    func loadDashboard() async {
    }
}

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    ProfileSummaryCard()

                    if let lpVM = viewModel.learningPlanVM {
                        LearningPlanView(viewModel: lpVM)
                    }

                    CategoryProgressView()
                }
                .padding()
            }
        }
        .task {
            await viewModel.loadDashboard()
        }
    }
}