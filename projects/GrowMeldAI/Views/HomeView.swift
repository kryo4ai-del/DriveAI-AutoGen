import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModelObject

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

class HomeViewModelObject: ObservableObject {
    @Published var learningPlanVM: LearningPlanViewModel? = nil

    func loadDashboard() async {
    }
}