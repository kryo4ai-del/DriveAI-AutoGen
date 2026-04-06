// MARK: - File: Views/NotificationConsentView.swift
import SwiftUI

struct NotificationConsentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: NotificationPermissionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // MARK: - Header with Clear Purpose
            VStack(alignment: .leading, spacing: 8) {
                Text("Benachrichtigungen für Lernfortschritt")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Erhalte hilfreiche Erinnerungen und Fortschritts-Updates")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Beschreibung der Benachrichtigungen")
            }
            
            Divider()
            
            // MARK: - Notification Types with Checkboxes
            VStack(alignment: .leading, spacing: 16) {
                Text("Benachrichtigungstypen")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                ForEach(NotificationType.allCases, id: \.self) { type in
                    NotificationTypeToggle(
                        type: type,
                        isSelected: viewModel.selectedTypes.contains(type),
                        action: {
                            viewModel.toggle(type)
                        }
                    )
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // MARK: - Data Usage Explanation
            VStack(alignment: .leading, spacing: 8) {
                Text("Datenschutz & Datenspeicherung")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Wir speichern deine Zustimmung für 90 Tage. Du kannst deine Einstellungen jederzeit in der App ändern.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Datenspeicherungserklärung")
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            // MARK: - Actions
            VStack(spacing: 12) {
                Button(action: { handleAccept() }) {
                    Text("Benachrichtigungen aktivieren")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityLabel("Benachrichtigungen aktivieren")
                .accessibilityHint("Zustimmung zu den ausgewählten Benachrichtigungstypen erteilen")
                
                Button(action: { handleDismiss() }) {
                    Text("Später entscheiden")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                .accessibilityLabel("Später entscheiden")
                .accessibilityHint("Schließe dieses Fenster ohne Benachrichtigungen zu aktivieren")
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .alert("Fehler", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.error?.errorDescription ?? "Ein Fehler ist aufgetreten")
        }
    }
    
    private func handleAccept() {
        Task {
            await viewModel.requestAuthorization()
            dismiss()
        }
    }
    
    private func handleDismiss() {
        dismiss()
    }
}

// MARK: - Accessible Toggle Component
struct NotificationTypeToggle: View {
    let type: NotificationType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .gray)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.displayTitle)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(type.accessibilityDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(type.displayTitle), \(type.accessibilityDescription)")
            .accessibilityHint(isSelected ? "Aktiviert" : "Nicht aktiviert")
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            .onTapGesture {
                action()
            }
        }
        .padding(.vertical, 8)
        .frame(minHeight: 44)
    }
}

extension NotificationType {
    var accessibilityDescription: String {
        switch self {
        case .examReadinessCheckpoint:
            return "Erinnert dich, wenn es Zeit ist zu trainieren"
        case .weakAreaAlert:
            return "Benachrichtigt dich über deine schwächsten Themen"
        case .streakMilestone:
            return "Feiert deine Trainings-Erfolge"
        case .examDateReminder:
            return "Erinnert dich an deinen Prüfungstag"
        case .dailyMotivation:
            return "Tägliche Motivations-Tipps"
        }
    }
}