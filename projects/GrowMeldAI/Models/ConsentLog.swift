struct ConsentLog: Codable, Identifiable {
    let timestamp: Date              // ❌ What is this for?
    let decision: LocationPermissionState  // ❌ Ambiguous to SR
    let context: String              // ❌ No description
    let withdrawalDate: Date?        // ❌ Optional, unclear purpose
    let lawfulBasis: String          // ❌ Legal text, not accessible
}