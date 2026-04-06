// Features/Onboarding/Views/ConfirmationScreen.swift
import SwiftUI

struct ConfirmationScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let userProfile: UserProfile
    let profileImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero section with emotional hook
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)

                    Text("Dein Profil ist bereit!")
                        .font(.title.bold())

                    Text("Du bist einen Schritt näher dran, sicher und selbstbewusst zu fahren.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Profile preview
                ProfilePreviewView(profile: userProfile, image: profileImage)

                // CTA
                Button(action: {
                    Task { await viewModel.completeOnboarding() }
                }) {
                    Text("Onboarding abschließen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)

                Button("Foto oder Daten bearbeiten") {
                    viewModel.editPhotoFromConfirmation()
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Zusammenfassung")
        .navigationBarTitleDisplayMode(.inline)
    }
}