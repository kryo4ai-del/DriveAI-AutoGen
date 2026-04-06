// File: AppView.swift
import SwiftUI

struct AppView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var examEngine = ExamEngine()

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
                .tag(AppCoordinator.AppTab.dashboard)

            PracticeView()
                .tabItem {
                    Label("Üben", systemImage: "book")
                }
                .tag(AppCoordinator.AppTab.practice)

            ExamSimulatorView()
                .tabItem {
                    Label("Prüfung", systemImage: "graduationcap")
                }
                .tag(AppCoordinator.AppTab.exam)

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
                .tag(AppCoordinator.AppTab.profile)
        }
        .environmentObject(examEngine)
    }
}