// MARK: - FeedbackBottomSheetView.swift
import SwiftUI

struct FeedbackBottomSheetView: View {
    @StateObject var viewModel: FeedbackBottomSheetVM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Feedback-Kategorie")) {
                    Picker("Kategorie", selection: $viewModel.selectedCategory) {
                        ForEach(FeedbackCategory.allCases, id: \.self) { category in
                            Text(category.germanLabel).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Deine Nachricht")) {
                    TextEditor(text: $viewModel.message)
                        .frame(minHeight: 120)
                        .accessibilityLabel("Feedback Nachricht")

                    if viewModel.message.count > 500 {
                        Text("Maximal 500 Zeichen")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Feedback senden")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Senden") {
                        Task { await viewModel.submitFeedback() }
                    }
                    .disabled(viewModel.message.isEmpty || viewModel.isSubmitting)
                }
            }
            .overlay {
                if viewModel.isSubmitting {
                    ProgressView()
                        .controlSize(.large)
                }
            }
            .alert("Fehler", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                if let error = viewModel.error {
                    Text(error.errorDescription ?? "Unbekannter Fehler")
                }
            }
            .alert("Danke!", isPresented: $viewModel.showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Deine \(viewModel.selectedCategory.germanLabel.lowercased()) hilft uns, DriveAI noch besser auf deine Prüfung vorzubereiten. Wir melden uns mit einer Antwort!")
            }
        }
    }
}