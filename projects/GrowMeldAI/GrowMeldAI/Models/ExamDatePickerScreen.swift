import SwiftUI

struct ExamDatePickerScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Wann ist dein Prüfungstermin?")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Das hilft uns, deinen Lernplan zu optimieren.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 32)
            
            // Date Picker
            DatePicker(
                "",
                selection: $viewModel.userProfile.examDate,
                in: Date.now...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .onChange(of: viewModel.userProfile.examDate) { newDate in
                viewModel.validateExamDate(newDate)
            }
            
            // Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            
            Spacer()
            
            // Navigation Buttons
            HStack(spacing: 12) {
                Button(action: { viewModel.previousStep() }) {
                    Text("Zurück")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(UIColor.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                
                Button(action: { viewModel.nextStep() }) {
                    Text("Weiter")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isDateValid)
                .opacity(viewModel.isDateValid ? 1 : 0.5)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    ExamDatePickerScreen(viewModel: OnboardingViewModel())
}