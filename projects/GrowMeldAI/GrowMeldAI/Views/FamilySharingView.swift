// MARK: - FamilySharingView.swift
import SwiftUI

struct FamilySharingView: View {
    @StateObject private var viewModel = FamilySharingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    benefitsSection
                    complianceSection
                    setupSection
                    footerSection
                }
                .padding()
            }
            .navigationTitle("Eltern-Freigabe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
            .interactiveDismissDisabled()
            .alert("Fehler", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue.gradient)

            Text("Lerne gemeinsam — sicher und privat")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text("Eltern können den Lernfortschritt einsehen, ohne die Privatsphäre ihrer Kinder zu verletzen.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Warum Eltern es lieben werden")
                .font(.headline)

            ForEach(viewModel.benefits, id: \.id) { benefit in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: benefit.icon)
                        .foregroundStyle(.blue)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(benefit.title)
                            .font(.subheadline.bold())
                        Text(benefit.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var complianceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Datenschutz & Compliance")
                .font(.headline)

            ForEach(viewModel.compliancePoints, id: \.id) { point in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: point.icon)
                        .foregroundStyle(.green)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(point.title)
                            .font(.subheadline.bold())
                        Text(point.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var setupSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Einrichtung in 3 Schritten")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.setupSteps, id: \.id) { step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(step.id).")
                            .font(.subheadline.bold())
                            .frame(width: 24, alignment: .trailing)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.title)
                                .font(.subheadline.bold())
                            Text(step.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("Bereit für sicheres Lernen?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: {
                viewModel.startSetup()
            }) {
                Text("Jetzt einrichten")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.top, 16)
    }
}

// MARK: - ViewModel

// MARK: - Models
struct Benefit: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct CompliancePoint: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct SetupStep: Identifiable {
    let id: Int
    let title: String
    let description: String
}

// MARK: - Preview
#Preview {
    FamilySharingView()
}