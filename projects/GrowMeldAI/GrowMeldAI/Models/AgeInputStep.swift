// MARK: - Views/Onboarding/AgeVerification/Steps/AgeInputStep.swift

import SwiftUI

struct AgeInputStep: View {
    @ObservedObject var viewModel: AgeVerificationViewModel
    
    @State private var ageInputText: String = ""
    @FocusState private var isAgeFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with context
                headerSection
                
                // Age input field
                ageInputSection
                
                // Help text
                helpSection
                
                Spacer(minLength: 32)
                
                // Action buttons
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemBackground))
        .onAppear {
            ageInputText = viewModel.state.userAge.map(String.init) ?? ""
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AgeVerificationStep.ageInput.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text("In Deutschland kannst du ab 17 Jahren mit Begleitung fahren (Begleitetes Fahren). Wir überprüfen dein Alter, um dir die richtige Vorbereitung anzubieten.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var ageInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Dein Alter", systemImage: "calendar")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("z.B. 16", text: $ageInputText)
                .keyboardType(.numberPad)
                .focused($isAgeFieldFocused)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .onChange(of: ageInputText) { newValue in
                    // Only allow digits, max 3 characters
                    let filtered = newValue.filter(\.isNumber).prefix(3)
                    ageInputText = String(filtered)
                    
                    if let age = Int(filtered) {
                        viewModel.setAge(age)
                    }
                }
                .accessibilityLabel("Alterseingabe")
                .accessibilityHint("Geben Sie Ihr Alter in Jahren ein")
        }
    }
    
    private var helpSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Warum fragen wir nach deinem Alter?", systemImage: "info.circle")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Für Benutzer unter 16 Jahren benötigen wir die E-Mail-Adresse eines Erziehungsberechtigten (COPPA-Regelung).")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { viewModel.advanceToNextStep() }) {
                Label("Weiter", systemImage: "arrow.right")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(viewModel.state.isAgeInputValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!viewModel.state.isAgeInputValid || viewModel.isProcessing)
            
            if viewModel.isProcessing {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    let viewModel = AgeVerificationViewModel()
    AgeInputStep(viewModel: viewModel)
}