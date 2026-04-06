// File: DriveAIBackupPresentationView.swift
import SwiftUI

/// SwiftUI view for displaying DriveAI backup system presentation
struct DriveAIBackupPresentationView: View {
    let presentation: UserPresentation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Emotional Hook
                Text(presentation.emotionalHook)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)

                // Feature Benefits
                VStack(alignment: .leading, spacing: 16) {
                    Text("Deine Vorteile:")
                        .font(.headline)
                        .padding(.bottom, 4)

                    ForEach(presentation.featureBenefits, id: \.self) { benefit in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .padding(.top, 2)
                            Text(benefit)
                        }
                    }
                }

                // Legal Disclaimers
                VStack(alignment: .leading, spacing: 12) {
                    Text("Wichtige Hinweise:")
                        .font(.headline)

                    ForEach(presentation.legalDisclaimers, id: \.self) { disclaimer in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .padding(.top, 2)
                            Text(disclaimer)
                        }
                    }
                }

                // Accessibility Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Barrierefreiheit:")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(presentation.accessibilityInfo.voiceOver)
                        Text(presentation.accessibilityInfo.dynamicType)
                        Text(presentation.accessibilityInfo.notifications)
                        Text(presentation.accessibilityInfo.contrast)
                    }
                }

                // Next Steps
                VStack(alignment: .leading, spacing: 12) {
                    Text("So geht's weiter:")
                        .font(.headline)

                    ForEach(presentation.nextSteps, id: \.self) { step in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.orange)
                                .padding(.top, 2)
                            Text(step)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("DriveAI Backup")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
struct DriveAIBackupPresentationView_Previews: PreviewProvider {
    static var previews: some View {
        let generator = DriveAIBackupPresentationGenerator()
        let presentation = generator.generateUserPresentation(
            userName: "Max",
            examDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())
        )

        NavigationView {
            DriveAIBackupPresentationView(presentation: presentation)
        }
    }
}