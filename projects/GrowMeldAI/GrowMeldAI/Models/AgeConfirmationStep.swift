// MARK: - Views/Onboarding/AgeVerification/Steps/AgeConfirmationStep.swift

import SwiftUI

struct AgeConfirmationStep: View {
    @ObservedObject var viewModel: AgeVerificationViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                confirmationCardSection
                
                Spacer(minLength: 32)
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemBackground))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressIndicator(
                current: AgeVerificationStep.ageConfirmation.stepNumber,
                total: 3
            )
            
            Text(AgeVerificationStep.ageConfirmation.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text("Bitte bestätige dein Alter")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var confirmationCardSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dein Alter")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(viewModel.state.userAge ?? 0) Jahre")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Conditional message based on age
            if viewModel.state.requiresParentalConsent {
                infoCard(
                    icon: "hand.raised.fill",
                    title: "Elternzustimmung erforderlich",
                    message: "Da du unter 16 Jahren alt bist, benötigen wir die E-Mail-Adresse eines Erziehungsberechtigten (COPPA).",
                    color: .orange
                )
            } else {
                infoCard(
                    icon: "checkmark.circle.fill",
                    title: "Alles klar!",
                    message: "Du kannst sofort mit dem Lernen beginnen.",
                    color: .green
                )
            }
        }
    }
    
    private func infoCard(
        icon: String,
        title: String,
        message: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { viewModel.confirmAge() }) {
                Label("Ja, ich bestätige", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(viewModel.isProcessing)
            
            Button(action: { viewModel.returnToPreviousStep() }) {
                Label("Zurück", systemImage: "arrow.left")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
            }
            .disabled(viewModel.isProcessing)
            
            if viewModel.isProcessing {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    let viewModel = AgeVerificationViewModel()
    viewModel.state.userAge = 15
    viewModel.state.hasConfirmedAge = false
    return AgeConfirmationStep(viewModel: viewModel)
}