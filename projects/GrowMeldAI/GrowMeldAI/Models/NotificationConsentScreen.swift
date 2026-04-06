// Features/NotificationConsent/Views/NotificationConsentScreen.swift
import SwiftUI

struct NotificationConsentScreen: View {
    @StateObject private var viewModel: NotificationConsentViewModel
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: NotificationConsentViewModel = NotificationConsentViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Hero Section
                VStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                        .accessibility(hidden: true)
                    
                    Text("Besteh deinen Führerschein – wir erinnern dich.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(3)
                    
                    Text("Erinnere dich täglich an deine Lernfortschritte und steigere deine Erfolgschance um 40%.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                }
                .multilineTextAlignment(.center)
                
                Spacer()
                
                // Benefits
                VStack(alignment: .leading, spacing: 12) {
                    BenefitRow(
                        icon: "checkmark.circle.fill",
                        text: "Tägliche Lernsträhne aufbauen",
                        accessibilityHint: "Erhalte tägliche Erinnerungen, um konsistent zu lernen"
                    )
                    
                    BenefitRow(
                        icon: "chart.line.uptrend.xyaxis",
                        text: "Fortschritt verfolgen",
                        accessibilityHint: "Sehe deine Verbesserungen in Echtzeit"
                    )
                    
                    BenefitRow(
                        icon: "star.fill",
                        text: "Examen-ready in 60 Tagen",
                        accessibilityHint: "Mit täglichen Erinnerungen bist du optimal vorbereitet"
                    )
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .accessibility(label: Text("Vorteile von Benachrichtigungen"))
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    // Primary Action
                    Button(action: handleConsent(true)) {
                        HStack(spacing: 8) {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            Text("Ja, erinnere mich")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isSubmitting)
                    .accessibilityHint("Aktiviert tägliche Benachrichtigungen zur Steigerung deiner Erfolgsaussichten")
                    
                    // Secondary Action
                    Button(action: handleConsent(false)) {
                        Text("Nicht jetzt")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isSubmitting)
                    .accessibilityHint("Überspringt die Benachrichtigungen für jetzt")
                }
                
                // Error State
                if case let .error(message) = viewModel.state {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 18))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fehler beim Speichern")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemOrange).opacity(0.1))
                    .cornerRadius(8)
                    .accessibilityElement(children: .combine)
                    .accessibility(label: Text("Fehler"))
                    
                    Button("Erneut versuchen") {
                        viewModel.retryAfterError()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)
        }
        .onChange(of: viewModel.state) { newState in
            // Dismiss only after successful save
            if case .completed = newState {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func handleConsent(_ consented: Bool) -> () -> Void {
        {
            viewModel.saveConsent(consented)
        }
    }
}

// MARK: - Benefit Row Component

// MARK: - Preview

#Preview {
    NotificationConsentScreen()
}