// PatentSearchView.swift
import SwiftUI

struct PatentSearchView: View {
    @StateObject private var viewModel = PatentSearchViewModel()
    @State private var showingVerificationDetails = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                contentView
            }
            .navigationTitle("Patent Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingVerificationDetails.toggle() }) {
                        Image(systemName: "checkmark.circle")
                    }
                }
            }
            .sheet(isPresented: $showingVerificationDetails) {
                VerificationDetailsView(verificationResults: viewModel.verificationResults)
            }
            .task {
                await viewModel.loadAllPatents()
            }
        }
    }

    private var searchBar: some View {
        HStack {
            TextField("Search patents...", text: $viewModel.searchQuery)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.clearSearch() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    private var contentView: some View {
        Group {
            if viewModel.isLoading && viewModel.patents.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                ErrorView(error: error, retryAction: { Task { await viewModel.loadAllPatents() } })
            } else if viewModel.patents.isEmpty {
                EmptyStateView()
            } else {
                patentsList
            }
        }
    }

    private var patentsList: some View {
        List(viewModel.patents) { patent in
            PatentRow(patent: patent, verificationResult: viewModel.verificationResults[patent.id])
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task {
                            do {
                                try await LocalPatentRepository().deletePatent(patent.id)
                                await viewModel.loadAllPatents()
                            } catch {
                                viewModel.errorMessage = "Failed to delete patent: \(error.localizedDescription)"
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .onTapGesture {
                    viewModel.selectedPatent = patent
                }
        }
        .listStyle(.plain)
    }
}

private struct PatentRow: View {
    let patent: Patent
    let verificationResult: VerificationResult?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(patent.title)
                .font(.headline)

            Text(patent.abstract)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                statusBadge
                Spacer()
                verificationBadge
            }
        }
        .padding(.vertical, 8)
    }

    private var statusBadge: some View {
        Text(patent.legalStatus.rawValue.capitalized)
            .font(.caption)
            .padding(4)
            .background(badgeColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    private var verificationBadge: some View {
        Group {
            if let result = verificationResult {
                Image(systemName: result.isVerified ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(result.isVerified ? .green : .orange)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.5)
            }
        }
    }

    private var badgeColor: Color {
        switch patent.legalStatus {
        case .granted: return .green
        case .pending: return .blue
        case .expired, .revoked, .lapsed: return .red
        }
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))

            Text("No patents found")
                .font(.title3)

            Text("Try a different search term or check your connection")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ErrorView: View {
    let error: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red.opacity(0.7))

            Text("Error")
                .font(.title3)
                .foregroundColor(.red)

            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: retryAction) {
                Text("Retry")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct VerificationDetailsView: View {
    let verificationResults: [UUID: VerificationResult]

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Verification Status")) {
                    ForEach(verificationResults.sorted(by: { $0.key.uuidString < $1.key.uuidString }), id: \.key) { id, result in
                        VerificationRow(patentId: id, result: result)
                    }
                }
            }
            .navigationTitle("Verification Results")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct VerificationRow: View {
    let patentId: UUID
    let result: VerificationResult

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(patentId.uuidString.prefix(8))
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)

                Text(result.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(4)
                    .background(result.isVerified ? Color.green : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }

            Spacer()

            Text(result.verificationDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}