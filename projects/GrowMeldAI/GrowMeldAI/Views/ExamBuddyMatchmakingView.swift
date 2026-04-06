// ExamBuddyMatchmakingView.swift
import SwiftUI
import Foundation

/// A view that helps users find study partners for driver's license exam preparation
struct ExamBuddyMatchmakingView: View {
    @StateObject private var viewModel = ExamBuddyMatchmakingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with motivational message
                headerSection
                    .padding(.bottom, 24)

                // Matchmaking controls
                matchmakingControls
                    .padding(.bottom, 24)

                // Buddy list
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.buddies.isEmpty {
                    emptyStateView
                } else {
                    buddyList
                }

                Spacer()
            }
            .navigationTitle("Exam Buddies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: { dismiss() })
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 40))
                .foregroundStyle(.blue)

            Text("Find Your Exam Buddy")
                .font(.title2.bold())

            Text("Connect with others preparing for their driver's license exam")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private var matchmakingControls: some View {
        VStack(spacing: 16) {
            // Location filter
            Picker("Location", selection: $viewModel.selectedLocation) {
                ForEach(ExamLocation.allCases) { location in
                    Text(location.rawValue).tag(location)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            // Study mode filter
            Picker("Study Mode", selection: $viewModel.selectedStudyMode) {
                ForEach(StudyMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            // Match button
            Button(action: viewModel.findBuddies) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Find Exam Buddies")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal, 16)
        }
    }

    private var buddyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.buddies) { buddy in
                    ExamBuddyCard(buddy: buddy)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No buddies found")
                .font(.title3.bold())

            Text("Try adjusting your filters or check back later")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Model for an exam buddy
struct ExamBuddy: Identifiable, Equatable {
    let id: UUID
    let name: String
    let location: ExamLocation
    let studyMode: StudyMode
    let progress: Double // 0.0 to 1.0
    let joinedDate: Date
    let commonTopics: [String]

    var formattedProgress: String {
        "\(Int(progress * 100))% complete"
    }
}

/// Exam location options

/// Study mode options
enum StudyMode: String, CaseIterable, Identifiable {
    case all = "All Modes"
    case online = "Online"
    case inPerson = "In-Person"
    case hybrid = "Hybrid"

    var id: String { rawValue }
}

/// View for displaying an individual exam buddy
struct ExamBuddyCard: View {
    let buddy: ExamBuddy

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Avatar
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(.blue)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(buddy.name)
                        .font(.headline)

                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.subheadline)
                        Text(buddy.location.rawValue)
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)

                    HStack {
                        Image(systemName: "book.fill")
                            .font(.subheadline)
                        Text(buddy.studyMode.rawValue)
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // Progress indicator
                VStack(alignment: .trailing) {
                    ProgressView(value: buddy.progress)
                        .progressViewStyle(.linear)
                        .frame(width: 80)

                    Text(buddy.formattedProgress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Common topics
            if !buddy.commonTopics.isEmpty {
                WrappingHStack(alignment: .leading) {
                    ForEach(buddy.commonTopics, id: \.self) { topic in
                        Text(topic)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: { /* Connect action */ }) {
                    Text("Connect")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: { /* Message action */ }) {
                    Image(systemName: "message.fill")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

/// ViewModel for the exam buddy matchmaking feature
final class ExamBuddyMatchmakingViewModel: ObservableObject {
    @Published var selectedLocation: ExamLocation = .all
    @Published var selectedStudyMode: StudyMode = .all
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var buddies: [ExamBuddy] = []

    private let buddyService: ExamBuddyServiceProtocol

    init(buddyService: ExamBuddyServiceProtocol = ExamBuddyService()) {
        self.buddyService = buddyService
    }

    @MainActor
    func findBuddies() async {
        isLoading = true
        defer { isLoading = false }

        do {
            buddies = try await buddyService.fetchBuddies(
                location: selectedLocation,
                studyMode: selectedStudyMode
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

/// Protocol for the exam buddy service
protocol ExamBuddyServiceProtocol {
    func fetchBuddies(location: ExamLocation, studyMode: StudyMode) async throws -> [ExamBuddy]
}

/// Concrete implementation of the exam buddy service
struct ExamBuddyService: ExamBuddyServiceProtocol {
    func fetchBuddies(location: ExamLocation, studyMode: StudyMode) async throws -> [ExamBuddy] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // In a real app, this would fetch from a backend service
        let mockBuddies: [ExamBuddy] = [
            ExamBuddy(
                id: UUID(),
                name: "Max Mustermann",
                location: .berlin,
                studyMode: .online,
                progress: 0.75,
                joinedDate: Date().addingTimeInterval(-86400 * 3),
                commonTopics: ["Verkehrsregeln", "Vorfahrt", "Geschwindigkeit"]
            ),
            ExamBuddy(
                id: UUID(),
                name: "Anna Schmidt",
                location: .munich,
                studyMode: .inPerson,
                progress: 0.45,
                joinedDate: Date().addingTimeInterval(-86400 * 7),
                commonTopics: ["Parken", "Abblendlicht", "Alkohol"]
            ),
            ExamBuddy(
                id: UUID(),
                name: "Tom Wagner",
                location: .hamburg,
                studyMode: .hybrid,
                progress: 0.92,
                joinedDate: Date().addingTimeInterval(-86400 * 1),
                commonTopics: ["Fahrtechnik", "Notbremsung"]
            )
        ]

        // Apply filters
        return mockBuddies.filter { buddy in
            (location == .all || buddy.location == location) &&
            (studyMode == .all || buddy.studyMode == studyMode)
        }
    }
}

/// Wrapping HStack for tags
struct WrappingHStack: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var lineWidth: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > (proposal.width ?? .infinity) {
                totalHeight += size.height
                lineWidth = size.width
            } else {
                lineWidth += size.width
            }
            totalWidth = max(totalWidth, lineWidth)
        }

        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var lineX = bounds.minX
        var lineY = bounds.minY

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if lineX + size.width > (bounds.maxX) {
                lineX = bounds.minX
                lineY += size.height
            }
            subview.place(at: CGPoint(x: lineX, y: lineY), proposal: ProposedViewSize(size))
            lineX += size.width
        }
    }
}