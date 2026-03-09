import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 28) {

            // Header
            VStack(spacing: 10) {
                Image(systemName: "car.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.blue)
                Text("Welcome to DriveAI")
                    .font(.largeTitle)
                    .bold()
                Text("Set your exam date to personalize your learning journey.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 16)

            // Date picker
            DatePicker(
                "Exam Date",
                selection: $viewModel.examDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()

            // Continue button -- triggers isCompleted, AppNavigationView switches to Dashboard
            Button(action: { viewModel.saveUserData() }) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .navigationTitle("Welcome")
        .navigationBarBackButtonHidden(true)
    }
}
