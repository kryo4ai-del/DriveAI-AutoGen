import SwiftUI
import Foundation

class GrowMeldHomeViewModel: ObservableObject {
    @Published var learningPlanVM: LearningPlanViewModel? = nil

    func loadDashboard() async {
    }
}

struct HomeView: View {
    @StateObject var viewModel: GrowMeldHomeViewModel

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