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
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // User info
                    if let user = viewModel.user {
                        UserInfoView(user: user)
                    }

                    // MARK: - Questions

                    sectionHeader("Fragen", color: .askFinPrimary)

                    primaryButton("Frage scannen", icon: "camera.fill", color: .askFinPrimary) {
                        showScanner = true
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        secondaryButton("Screenshot", icon: "photo.fill", color: .askFinPrimary) {
                            showImageImport = true
                        }
                        secondaryButton("Verlauf", icon: "clock.arrow.circlepath", color: .askFinPrimary) {
                            showHistory = true
                        }
                        secondaryButton("Insights", icon: "chart.bar.fill", color: .askFinPrimary) {
                            showInsights = true
                        }
                        secondaryButton("Statistik", icon: "chart.pie.fill", color: .askFinPrimary) {
                            showStatistics = true
                        }
                    }

                    // Divider with glow hint
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.askFinPrimary.opacity(0.4), .askFinAccent.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.vertical, 4)

                    // MARK: - Traffic Signs

                    sectionHeader("Verkehrszeichen", color: .askFinAccent)

                    primaryButton("Zeichen erkennen", icon: "exclamationmark.triangle.fill", color: .askFinAccent) {
                        showTrafficSigns = true
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        secondaryButton("Verlauf", icon: "clock.badge.fill", color: .askFinAccent) {
                            showSignHistory = true
                        }
                        secondaryButton("Statistik", icon: "chart.bar.doc.horizontal.fill", color: .askFinAccent) {
                            showSignStatistics = true
                        }
                    }

                    secondaryButton("Schwachstellen", icon: "exclamationmark.circle.fill", color: .askFinAccent) {
                        showSignWeaknesses = true
                    }
                }
                .padding()
            }
            .navigationTitle("AskFin")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(Color.askFinPrimary.opacity(0.8))
                    }
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
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

    private func sectionHeader(_ title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(width: 3, height: 20)
                .cornerRadius(2)
            Text(title)
                .font(.title2)
                .bold()
        }
    }

    // MARK: - Primary action button

    private func primaryButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(color == .askFinPrimary ? Color.askFinBackground : .white)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: color.opacity(AppTheme.glowOpacity), radius: AppTheme.glowRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .stroke(color.opacity(AppTheme.borderOpacity), lineWidth: 1)
                )
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
            .background(color.opacity(0.10))
            .cornerRadius(AppTheme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .stroke(color.opacity(0.18), lineWidth: 1)
            )
        }
    }
}
