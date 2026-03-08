import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        VStack {
            Text("Your Progress")
                .font(.headline)
            // Display progress bar and stats here
            Button("Start Quiz") {
                viewModel.startQuiz()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}