import SwiftUI
import Foundation

class HomeViewModel: ObservableObject {
    @Published var learningPlanVM: LearningPlanViewModel? = nil

    func loadDashboard() async {
        // Load dashboard data
    }
}

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