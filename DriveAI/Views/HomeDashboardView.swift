import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var showHistory = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Welcome to DriveAI")
                    .font(.largeTitle)
                    .padding(.top)

                if let user = viewModel.user {
                    UserInfoView(user: user)

                    Button(action: { viewModel.startQuiz() }) {
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
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showHistory = true }) {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                }
            }
            .navigationDestination(isPresented: $showHistory) {
                QuestionHistoryView()
            }
            .onAppear { viewModel.loadUserData() }
        }
    }
}