// MARK: - HeroSectionView.swift
import SwiftUI

struct HeroSectionView: View {
    let onDownloadTapped: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Emotional transformation headline
            VStack(spacing: 8) {
                Text("Vom Blackout zur Bestnote")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text("in 21 Tagen")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal)

            // App screenshot with realistic UI
            Image("hero-screenshot")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.vertical)

            // Emotional CTA
            VStack(spacing: 12) {
                Text("Bereit für deine Prüfung?")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Button(action: onDownloadTapped) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.app.fill")
                        Text("Jetzt laden")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}