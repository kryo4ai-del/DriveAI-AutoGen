struct PermissionInfo: Identifiable {
    let id: UUID = UUID()
    let key: PermissionKey
    let title: String
    let description: String
    let accessibilityHint: String
    let accessibilityIdentifier: String  // ← ADD
    
    init(key: PermissionKey, title: String, description: String, accessibilityHint: String) {
        self.key = key
        self.title = title
        self.description = description
        self.accessibilityHint = accessibilityHint
        self.accessibilityIdentifier = "permission.\(key.rawValue)"  // ← ADD
    }
}