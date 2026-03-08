import SwiftUI

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var showScanner = false
    @State private var showImageImport = false
    @State private var showHistory = false
    @State private var showInsights = false
    @State private var showStatistics = false
    @State private var showTrafficSigns = false
    @State private var showSignHistory = false
    @State private var showSignStatistics = false
    @State private var showSignWeaknesses = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // User info
                    if let user = viewModel.user {
                        UserInfoView(user: user)
                    }

                    // MARK: - Questions

                    sectionHeader("Questions")

                    primaryButton("Scan Question", icon: "camera.fill", color: .blue) {
                        showScanner = true
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        secondaryButton("Import Screenshot", icon: "photo.fill", color: .blue) {
                            showImageImport = true
                        }
                        secondaryButton("History", icon: "clock.arrow.circlepath", color: .blue) {
                            showHistory = true
                        }
                        secondaryButton("Insights", icon: "chart.bar.fill", color: .blue) {
                            showInsights = true
                        }
                        secondaryButton("Statistics", icon: "chart.pie.fill", color: .blue) {
                            showStatistics = true
                        }
                    }

                    // MARK: - Traffic Signs

                    sectionHeader("Traffic Signs")

                    primaryButton("Recognize Sign", icon: "exclamationmark.triangle.fill", color: .orange) {
                        showTrafficSigns = true
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        secondaryButton("Sign History", icon: "clock.badge.fill", color: .orange) {
                            showSignHistory = true
                        }
                        secondaryButton("Sign Statistics", icon: "chart.bar.doc.horizontal.fill", color: .orange) {
                            showSignStatistics = true
                        }
                    }

                    secondaryButton("Sign Weaknesses", icon: "exclamationmark.circle.fill", color: .orange) {
                        showSignWeaknesses = true
                    }
                }
                .padding()
            }
            .navigationTitle("DriveAI")
            .navigationDestination(isPresented: $showScanner) {
                ScannerView()
            }
            .navigationDestination(isPresented: $showImageImport) {
                ImageImportView()
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

    // MARK: - Section header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .bold()
    }

    // MARK: - Primary action button

    private func primaryButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }

    // MARK: - Secondary action button

    private func secondaryButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color.opacity(0.09))
            .cornerRadius(12)
        }
    }
}
