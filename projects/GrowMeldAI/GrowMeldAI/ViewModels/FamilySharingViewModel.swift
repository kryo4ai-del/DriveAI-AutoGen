class FamilySharingViewModel: ObservableObject {
    @Published var currentUserID: UUID
    @Published var familyMembers: [FamilyMember] = []
    
    private let familySharingService: FamilySharingService
    
    // IMPORTANT: Only fetch members if user is family organizer
    @MainActor
    func loadFamilyMembers() async {
        guard await familySharingService.isFamilyOwner() else {
            familyMembers = []  // Non-owners see empty list
            return
        }
        familyMembers = await familySharingService.getFamilyMembers()
    }
    
    // Exam progress sharing: MUST be explicit design decision
    func canViewMemberProgress(memberID: UUID) -> Bool {
        // Only organizer can view; non-owners cannot access sibling progress
        return currentUserID == familyGroupID.organizerID
    }
    
    // Remove family member: MUST verify ownership first
    @MainActor
    func removeFamilyMember(_ memberID: UUID) async throws {
        guard await familySharingService.isFamilyOwner() else {
            throw FamilySharingError.notAuthorized
        }
        try await familySharingService.removeMember(memberID)
    }
}