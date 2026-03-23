import SwiftUI

struct BreathFlowEntryView: View {

    @StateObject private var viewModel = BreathFlowEntryViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    anxietySection
                    patternSection
                    Spacer(minLength: 8)
                    startButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { skipButton }
            .navigationDestination(
                isPresented: Binding(
                    get: { viewModel.navigationDestination == .session },
                    set: { if !$0 { viewModel.clearNavigation() } }
                )
            ) {
                if let sessionVM = viewModel.pendingSessionViewModel {
                    BreathFlowSessionView(viewModel: sessionVM)
                }
            }
            .sheet(isPresented: $viewModel.showPatternPicker) {
                PatternPickerSheet(
                    selectedPattern: viewModel.recommendedPattern,
                    onSelect: { viewModel.selectPattern($0) }
                )
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lungs.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Dein Kopf ist schon in der Prüfung\n— hol ihn kurz zurück.")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var anxietySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wie nervös bist du gerade?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            AnxietyPicker(
                selected: $viewModel.selectedAnxiety,
                onChange: { viewModel.confirmAnxietyLevel() }
            )
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var patternSection: some View {
        PatternCard(
            pattern: viewModel.recommendedPattern,
            descriptionText: viewModel.patternDescription,
            durationLabel: viewModel.estimatedDurationLabel,
            onChangeTap: { viewModel.showPatternPicker = true }
        )
    }

    private var startButton: some View {
        Button(action: viewModel.startSession) {
            Text("Atemübung starten")
                .font(.body)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    @ToolbarContentBuilder
    private var skipButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Überspringen") {
                viewModel.skipBreathFlow()
                dismiss()
            }
            .foregroundStyle(.secondary)
        }
    }
}