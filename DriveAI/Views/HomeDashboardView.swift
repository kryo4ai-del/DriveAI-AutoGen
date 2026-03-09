import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()

    var body: some View {
        VStack {
            Text("Welcome to DriveAI")
                .font(.largeTitle)
                .padding()

            if let user = viewModel.user {
                UserInfoView(user: user)
                
                Button(action: {
                    viewModel.startQuiz()
                    // Insert navigation logic to Quiz screen
                }) {
                    Text("Start Quiz")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Text("No user data found. Please set your exam date.")
            }
        }
        .onAppear {
            viewModel.loadUserData()
        }
        .padding()
        .navigationTitle("Dashboard")
    }
}