// Models/AIModelStatusBadge.swift
import SwiftUI

// MARK: - Supporting Types

enum AIModelStatus {
    case available
    case degraded
    case unavailable
}

enum FallbackTier {
    case local
    case cached
    case offline
}

// MARK: - View

struct AIModelStatusBadge: View {
    let status: AIModelStatus
    let fallbackTier: FallbackTier?

    var body: some View {
        HStack(spacing: 4) {
            switch status {
            case .available:
                Image(systemName: "network")
                Text("Live")
                    .font(.caption)
            case .degraded:
                Image(systemName: "exclamationmark.circle.fill")
                Text("Offline")
                    .font(.caption)
                    .foregroundColor(.orange)
            case .unavailable:
                Image(systemName: "wifi.slash")
                Text("Offline Mode")
                    .foregroundColor(.red)
            }
        }
        .accessibilityLabel("AI Status: \(statusDescription)")
    }

    private var statusDescription: String {
        switch status {
        case .available:   return "Available"
        case .degraded:    return "Degraded"
        case .unavailable: return "Unavailable"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AIModelStatusBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            AIModelStatusBadge(status: .available, fallbackTier: nil)
            AIModelStatusBadge(status: .degraded, fallbackTier: .cached)
            AIModelStatusBadge(status: .unavailable, fallbackTier: .offline)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif