import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        VStack {
            Text("Set Your Exam Date")
                .font(.title)
                .padding(.bottom)
            
            DatePicker("Exam Date", selection: $viewModel.examDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
            
            NavigationLink(destination: HomeDashboardView()) {
                Button(action: {
                    viewModel.saveUserData()
                }) {
                    Text("Continue")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Onboarding")
    }
}