import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var showHistory = false
    @State private var showInsights = false
    @State private var showStatistics = false
    @State private var showTrafficSigns = false
    @State private var showSignHistory = false
    @State private var showSignStatistics = false
    @State private var showSignWeaknesses = false

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

                Button(action: { showInsights = true }) {
                    Label("Learning Insights", systemImage: "chart.bar.fill")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }

                Button(action: { showStatistics = true }) {
                    Label("Learning Statistics", systemImage: "chart.pie.fill")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(8)
                }

                Button(action: { showTrafficSigns = true }) {
                    Label("Traffic Signs", systemImage: "exclamationmark.triangle.fill")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }

                Button(action: { showSignHistory = true }) {
                    Label("Traffic Sign History", systemImage: "clock.badge.exclamationmark.fill")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.07))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }

                Button(action: { showSignStatistics = true }) {
                    Label("Sign Statistics", systemImage: "chart.bar.doc.horizontal.fill")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.05))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }

                Button(action: { showSignWeaknesses = true }) {
                    Label("Traffic Sign Weaknesses", systemImage: "exclamationmark.triangle.fill")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.08))
                        .foregroundColor(.red)
                        .cornerRadius(8)
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
            .navigationDestination(isPresented: $showInsights) {
                LearningInsightsView()
            }
            .navigationDestination(isPresented: $showStatistics) {
                LearningStatisticsView()
            }
            .navigationDestination(isPresented: $showTrafficSigns) {
                TrafficSignRecognitionView()
            }
            .navigationDestination(isPresented: $showSignHistory) {
                TrafficSignHistoryView()
            }
            .navigationDestination(isPresented: $showSignStatistics) {
                TrafficSignStatisticsView()
            }
            .navigationDestination(isPresented: $showSignWeaknesses) {
                TrafficSignWeaknessView()
            }
            .onAppear { viewModel.loadUserData() }
        }
    }
}