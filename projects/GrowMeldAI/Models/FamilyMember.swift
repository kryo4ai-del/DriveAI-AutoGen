// FamilyMember.swift
import Foundation

struct FamilyMember: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let email: String
    let subscriptionTier: SubscriptionTier
    let joinDate: Date
    let isOwner: Bool

    // For testing
    static let mock: FamilyMember = FamilyMember(
        id: UUID(),
        name: "Max Mustermann",
        email: "max@example.com",
        subscriptionTier: .premium,
        joinDate: Date(),
        isOwner: false
    )
}