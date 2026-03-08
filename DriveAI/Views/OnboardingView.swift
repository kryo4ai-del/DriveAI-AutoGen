import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack {
            Text("Welcome to DriveAI")
                .font(.largeTitle)
                .padding()
            DatePicker("Pick your exam date:", selection: $viewModel.examDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            Button("Start Learning") {
                viewModel.startLearning()
            }
            .buttonStyle(PrimaryButtonStyle())
            Spacer()
        }
        .padding()
    }
}