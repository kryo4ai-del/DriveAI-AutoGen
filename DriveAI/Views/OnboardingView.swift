// Views/OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                PageViewController(pages: viewModel.screens, currentPage: $viewModel.currentPage)
                navigationButtons
            }
            .navigationBarHidden(true)
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            NavigationLink(destination: ExamDateSetupView()) {
                Button("Next") {
                    viewModel.nextPage()
                }
            }
            .disabled(viewModel.currentPage == viewModel.totalPages - 1)

            Spacer()
            
            Button(action: {
                viewModel.skipOnboarding()
                // Navigate to Exam Date Setup
            }) {
                Text("Skip")
            }
        }
        .padding()
        .font(.headline) // Increased font size for better visibility
    }
}