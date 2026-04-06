import SwiftUI

/// FIXED: Proper accessibility hierarchy without over-combining elements
struct SyncStatusView: View {
    @ObservedObject var viewModel: BackupViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        HStack(spacing: 12) {
            // Status icon (decorative, hidden from VoiceOver)
            statusIndicator
            
            // Primary message + optional timestamp
            statusInfoSection
            
            Spacer()
            
            // Action button (separately accessible)
            syncNowButton
        }
        .frame(minHeight: 44) // Touch target for entire row
        .contentShape(Rectangle()) // Expand hitbox
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
        // NOTE: Do NOT use .accessibilityElement(children: .combine)
        // Let subviews remain individually accessible
        .accessibilityElement(children: .contain) // Logical grouping
    }
    
    // FIXED: Decorative icon, always hidden
    @ViewBuilder
    private var statusIndicator: some View {
        Group {
            switch viewModel.syncState {
            case .syncing:
                syncingIndicator
            case .synced:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .offline:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
            case .error:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .font(.title3)
        .accessibilityHidden(true) // Icon is decorative; label sufficient
    }
    
    // FIXED: Reduced motion safe, properly hidden
    private var syncingIndicator: some View {
        Group {
            if reduceMotion {
                // Show static indicator for users with motion sensitivity
                ProgressView()
                    .scaleEffect(0.9)
            } else {
                Image(systemName: "arrow.clockwise")
                    .rotationEffect(.degrees(viewModel.isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: viewModel.isAnimating
                    )
            }
        }
    }
    
    // FIXED: Separate status and timestamp for proper VoiceOver flow
    @ViewBuilder
    private var statusInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Primary status message
            Text(viewModel.syncState.displayTitle)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .accessibilityLabel("Synchronisierungsstatus")
                .accessibilityValue(viewModel.syncState.displayTitle)
            
            // Secondary timestamp (optional, properly contrasted)
            if let lastSync = viewModel.lastSyncDate {
                Text("Vor \(timeAgoString(lastSync))")
                    .font(.caption)
                    .foregroundColor(.primary) // FIXED: Use .primary for 4.5:1+ contrast
                    .lineLimit(1)
                    .accessibilityLabel("Letzte Synchronisierung")
                    .accessibilityValue(timeAgoString(lastSync))
            }
        }
        .fixedSize(horizontal: false, vertical: true) // Allow wrapping for German text
    }
    
    // FIXED: Touch target 44x44 applied at button level, not icon
    private var syncNowButton: some View {
        Button(action: { viewModel.syncNow() }) {
            Image(systemName: "arrow.clockwise")
                .font(.body)
        }
        .frame(minWidth: 44, minHeight: 44) // FIXED: Applied to button, not image
        .contentShape(Rectangle()) // Expand hitbox to full frame
        .disabled(viewModel.syncState == .syncing)
        .accessibilityLabel("Jetzt synchronisieren")
        .accessibilityHint("Synchronisiert sofort mit allen Sicherungsmethoden")
        .accessibilityAddTraits(.isButton)
    }
    
    // FIXED: Localized time string with proper German pluralization
    private func timeAgoString(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return String(localized: "Gerade eben", defaultValue: "Gerade eben")
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return String(localized: "\(minutes) \(minutes == 1 ? "Minute" : "Minuten")",
                         defaultValue: "\(minutes) Minuten")
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return String(localized: "\(hours) \(hours == 1 ? "Stunde" : "Stunden")",
                         defaultValue: "\(hours) Stunden")
        } else {
            let days = Int(interval / 86400)
            return String(localized: "Vor \(days) \(days == 1 ? "Tag" : "Tagen")",
                         defaultValue: "Vor \(days) Tagen")
        }
    }
}

// FIXED: Semantic enum for sync state
enum SyncState: String, CaseIterable {
    case syncing
    case synced
    case offline
    case error
    
    var displayTitle: String {
        switch self {
        case .syncing:
            return String(localized: "Dein Fortschritt wird gesichert...", 
                        defaultValue: "Dein Fortschritt wird gesichert...")
        case .synced:
            return String(localized: "Fortschritt gesichert ✓", 
                        defaultValue: "Fortschritt gesichert ✓")
        case .offline:
            return String(localized: "Offline – Änderungen werden lokal gespeichert",
                        defaultValue: "Offline – Änderungen werden lokal gespeichert")
        case .error:
            return String(localized: "Synchronisierung fehlgeschlagen",
                        defaultValue: "Synchronisierung fehlgeschlagen")
        }
    }
}

#Preview {
    SyncStatusView(viewModel: BackupViewModel())
        .padding()
}