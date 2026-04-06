// ✅ FIXED: AuthContainerView.swift

import SwiftUI

struct AuthContainerView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            // Background gradient (ignores safe area)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color(UIColor.secondarySystemBackground)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content (respects safe area)
            VStack(spacing: 0) {
                Group {
                    switch viewModel.currentStep {
                    case .onboarding:
                        OnboardingView(viewModel: viewModel)
                        
                    case .examDatePicker:
                        ExamDatePickerView(viewModel: viewModel)
                        
                    case .signUpForm(let examDate):
                        SignUpFormView(viewModel: viewModel, examDate: examDate)
                        
                    case .verification:
                        VerificationView(viewModel: viewModel)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
            .padding()
        }
        .alert(item: $viewModel.errorAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK")) {
                    alert.action?()
                }
            )
        }
    }
}