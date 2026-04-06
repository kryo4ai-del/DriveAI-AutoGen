// File: DriveAI/Views/AppRootView.swift
import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        Group {
            switch coordinator.currentRoute {
            case .onboarding:
                OnboardingView()
            case .main:
                MainTabView()
            case .exam(let config):
                ExamView(configuration: config)
            case .categoryDetail(let category):
                CategoryDetailView(category: category)
            }
        }
    }
}