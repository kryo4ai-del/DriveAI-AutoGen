import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    init(localDataService: LocalDataService = .shared) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(localDataService: localDataService))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Exam Management
                Section("Prüfungsvorbereitung") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Prüfungsdatum", systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        DatePicker(
                            "Datum",
                            selection: $viewModel.examDate,
                            in: Date.now...Date.distantFuture,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    Button(role: .destructive) {
                        viewModel.showResetConfirmation = true
                    } label: {
                        Label("Fortschritt zurücksetzen", systemImage: "arrow.counterclockwise")
                    }
                }
                
                // MARK: - User Experience
                Section("Benutzerfreundlichkeit") {
                    Toggle(isOn: $viewModel.enableHaptics) {
                        Label("Haptisches Feedback", systemImage: "hand.tap")
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Textgröße", systemImage: "textformat.size")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            Text("A").font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Slider(
                                value: $viewModel.textSizeMultiplier,
                                in: 0.8...1.5,
                                step: 0.1
                            )
                            
                            Text("A").font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Voransicht")
                            .font(.system(size: 16 * viewModel.textSizeMultiplier))
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - App Info
                Section("Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
        .confirmationDialog(
            "Fortschritt löschen?",
            isPresented: $viewModel.showResetConfirmation,
            actions: {
                Button("Zurücksetzen", role: .destructive) {
                    viewModel.resetProgress()
                }
                Button("Abbrechen", role: .cancel) { }
            },
            message: {
                Text("Alle Fragen und Fortschritt werden gelöscht. Dies kann nicht rückgängig gemacht werden.")
            }
        )
        .overlay(alignment: .top) {
            if viewModel.resetSuccess {
                VStack {
                    Label("Fortschritt zurückgesetzt", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}