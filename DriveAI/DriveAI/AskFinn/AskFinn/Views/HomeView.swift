import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Progress: \(viewModel.progress)")
                NavigationLink(destination: QuizView(viewModel: QuizViewModel())) {
                    Text("Start Quiz")
                        .padding()
                }
            }
        }
    }
}