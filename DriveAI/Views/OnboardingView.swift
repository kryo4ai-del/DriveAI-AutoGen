import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack {
            Text("Welcome to DriveAI")
                .font(.largeTitle)
                .padding()
            DatePicker("Select Exam Date", selection: $viewModel.examDate, displayedComponents: .date)
                .padding()
            
            Button("Next") {
                viewModel.completeOnboarding()
            }
            .disabled(!viewModel.isReady)
            .opacity(viewModel.isReady ? 1.0 : 0.5) // Visual feedback for state
            .padding()
        }
    }
}