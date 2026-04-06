// Features/NotificationConsent/Resources/ConsentStrings.swift
import Foundation
import SwiftUI

enum ConsentStrings {
    // German (de) — primary
    static let title = NSLocalizedString(
        "notification_consent.title",
        comment: "Consent sheet title — emotionally-grounded"
    )
    
    static let subtitle = NSLocalizedString(
        "notification_consent.subtitle",
        comment: "Consent sheet subtitle — data-driven benefit"
    )
    
    static let benefit1Title = NSLocalizedString(
        "notification_consent.benefit1.title",
        comment: "Benefit: consistency"
    )
    
    static let benefit1Description = NSLocalizedString(
        "notification_consent.benefit1.description",
        comment: "Benefit: daily habit"
    )
    
    static let acceptButton = NSLocalizedString(
        "notification_consent.accept",
        comment: "Accept button — action-oriented"
    )
    
    static let declineButton = NSLocalizedString(
        "notification_consent.decline",
        comment: "Decline button"
    )
    
    static func deferButton(remaining: Int) -> String {
        String(
            format: NSLocalizedString(
                "notification_consent.defer",
                comment: "Defer button with remaining count"
            ),
            remaining
        )
    }
}