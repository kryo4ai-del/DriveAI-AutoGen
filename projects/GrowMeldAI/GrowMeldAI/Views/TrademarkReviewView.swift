// File: DriveAI/Views/Compliance/TrademarkReviewView.swift
import SwiftUI

struct TrademarkReviewView: View {
    @EnvironmentObject var complianceService: ComplianceService
    @State private var showingDomainDetail = false
    @State private var selectedDomain: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with emotional hook
                VStack(spacing: 12) {
                    Image(systemName: "shield.checkerboard")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    Text("Dein Name ist sicher")
                        .font(.title.bold())
                    Text("Wir prüfen deine Markenrechte in DE, AT und CH")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)

                // Overall Status
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gesamtstatus")
                        .font(.headline)
                    HStack {
                        Text(complianceService.trademarkCompliance.overallStatus.rawValue)
                            .font(.subheadline)
                            .padding(8)
                            .background(statusColor)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        Spacer()
                        if complianceService.trademarkCompliance.searchDate != nil {
                            Text("Geprüft: \(formattedDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                // Region Results
                VStack(alignment: .leading, spacing: 16) {
                    Text("Regionale Prüfung")
                        .font(.headline)

                    ForEach(complianceService.trademarkCompliance.results) { result in
                        RegionResultView(result: result)
                    }
                }
                .padding(.horizontal)

                // Domain Availability
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Domain-Verfügbarkeit")
                            .font(.headline)
                        Spacer()
                        Button("Details") {
                            showingDomainDetail = true
                        }
                        .buttonStyle(.bordered)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                        ForEach(Array(complianceService.trademarkCompliance.domainAvailability.sorted(by: { $0.key < $1.key })), id: \.key) { domain, isAvailable in
                            DomainStatusView(domain: domain, isAvailable: isAvailable)
                        }
                    }
                }
                .padding(.horizontal)

                // Action Button
                if complianceService.trademarkCompliance.overallStatus != .cleared {
                    Button(action: {
                        // In a real app, this would open a web view for trademark search
                        print("Starting trademark search...")
                    }) {
                        Text("Markenprüfung starten")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationTitle("Markenrechtliche Prüfung")
        .sheet(isPresented: $showingDomainDetail) {
            DomainDetailView()
                .environmentObject(complianceService)
        }
    }

    private var statusColor: Color {
        switch complianceService.trademarkCompliance.overallStatus {
        case .notStarted, .inProgress: return .gray
        case .cleared: return .green
        case .conflictFound: return .red
        case .requiresAction: return .orange
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: complianceService.trademarkCompliance.searchDate ?? Date())
    }
}

struct RegionResultView: View {
    let result: TrademarkSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.region)
                    .font(.subheadline.bold())
                Spacer()
                Text(result.status.rawValue)
                    .font(.caption)
                    .padding(6)
                    .background(statusColor)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }

            if !result.similarMarks.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ähnliche Marken:")
                        .font(.caption.bold())
                    ForEach(result.similarMarks, id: \.self) { mark in
                        Text("• \(mark)")
                            .font(.caption)
                    }
                }
            }

            if let notes = result.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private var statusColor: Color {
        switch result.status {
        case .notStarted, .inProgress: return .gray
        case .cleared: return .green
        case .conflictFound: return .red
        case .requiresAction: return .orange
        }
    }
}

struct DomainStatusView: View {
    let domain: String
    let isAvailable: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(domain)
                .font(.caption.monospaced())
                .lineLimit(1)
            Text(isAvailable ? "Verfügbar" : "Belegt")
                .font(.caption.bold())
                .padding(4)
                .frame(maxWidth: .infinity)
                .background(isAvailable ? Color.green : Color.red)
                .foregroundColor(.white)
                .cornerRadius(4)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct DomainDetailView: View {
    @EnvironmentObject var complianceService: ComplianceService

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Verfügbare Domains")) {
                    ForEach(Array(complianceService.trademarkCompliance.domainAvailability.filter { $0.value }.sorted(by: { $0.key < $1.key })), id: \.key) { domain, _ in
                        Text(domain)
                            .font(.caption.monospaced())
                    }
                }

                Section(header: Text("Belegte Domains")) {
                    ForEach(Array(complianceService.trademarkCompliance.domainAvailability.filter { !$0.value }.sorted(by: { $0.key < $1.key })), id: \.key) { domain, _ in
                        Text(domain)
                            .font(.caption.monospaced())
                    }
                }
            }
            .navigationTitle("Domain-Verfügbarkeit")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        // Dismiss sheet
                    }
                }
            }
        }
    }
}