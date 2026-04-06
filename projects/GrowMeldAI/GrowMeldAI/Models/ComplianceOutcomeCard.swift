// Views/ComplianceOutcomeCard.swift

import SwiftUI

struct ComplianceOutcomeCard: View {
    let consentType: ConsentType
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(consentType.outcomeConfirmation)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(isEnabled ? "Deine Kontrolle ist aktiv" : "Einstellung geändert")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ComplianceOutcomeCard(
        consentType: .examResultsStorage,
        isEnabled: true
    )
    .padding()
}