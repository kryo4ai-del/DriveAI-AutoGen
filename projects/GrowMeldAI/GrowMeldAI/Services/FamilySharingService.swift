import Foundation

/// Manages family group membership and entitlements
@MainActor
final class FamilySharingService: ObservableObject {
    static let shared = FamilySharingService()
    
    @Published var familyMembers: [FamilyMember] = []
    @Published var isFamilyOwner: Bool = false
    @Published var familyGroupID: String?
    @Published var isLoading = false
    @Published var error: FamilySharingError?
    
    private let defaults = UserDefaults.standard
    private let keychain = KeychainService.shared
    
    // MARK: - Family Membership
    
    func loadFamilyStatus(for userID: UUID) async {
        isLoading = true
        
        // In offline-first MVP, family status comes from cached entitlements
        // Phase 3 can integrate with Apple's Family Sharing API or backend
        
        familyGroupID = defaults.string(forKey: "family_group_id_\(userID)")
        isFamilyOwner = defaults.bool(forKey: "is_family_owner_\(userID)")
        
        if isFamilyOwner {
            await loadFamilyMembers(for: userID)
        }
        
        isLoading = false
    }
    
    private func loadFamilyMembers(for userID: UUID) async {
        guard let groupID = familyGroupID else { return }
        
        // Fetch from local cache (Phase 1)
        // Backend sync deferred to Phase 3
        if let stored = defaults.data(forKey: "family_members_\(groupID)") {
            familyMembers = (try? JSONDecoder().decode([FamilyMember].self, from: stored)) ?? []
        }
    }
    
    func addFamilyMember(_ member: FamilyMember) async throws {
        guard isFamilyOwner else {
            throw FamilySharingError.notAuthorized
        }
        
        familyMembers.append(member)
        
        // Persist locally
        if let encoded = try? JSONEncoder().encode(familyMembers),
           let groupID = familyGroupID {
            defaults.set(encoded, forKey: "family_members_\(groupID)")
        }
    }
    
    func removeFamilyMember(_ memberID: UUID) async throws {
        guard isFamilyOwner else {
            throw FamilySharingError.notAuthorized
        }
        
        familyMembers.removeAll { $0.id == memberID }
        
        // Persist locally
        if let encoded = try? JSONEncoder().encode(familyMembers),
           let groupID = familyGroupID {
            defaults.set(encoded, forKey: "family_members_\(groupID)")
        }
    }
    
    // MARK: - Entitlement Checking
    
    func canAccessFamilyFeatures() -> Bool {
        return isFamilyOwner && !familyMembers.isEmpty
    }
    
    func getFamilyMemberCount() -> Int {
        return familyMembers.count
    }
}

// MARK: - Models

struct FamilyMember: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
    let role: FamilyRole
    let addedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, role
        case addedDate = "added_date"
    }
}

enum FamilyRole: String, Codable {
    case organizer
    case member
    
    var localizedName: String {
        switch self {
        case .organizer:
            return "Organisator"
        case .member:
            return "Mitglied"
        }
    }
}

enum FamilySharingError: LocalizedError {
    case notAuthorized
    case familyGroupNotFound
    case invalidMemberData
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Sie sind nicht berechtigt, Familienmitglieder zu verwalten."
        case .familyGroupNotFound:
            return "Familiengruppe nicht gefunden."
        case .invalidMemberData:
            return "Ungültige Mitgliederdaten."
        }
    }
}