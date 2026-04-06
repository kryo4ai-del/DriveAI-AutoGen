struct UserProfileData: Identifiable {
    let name: String  // immutable
    let examDate: Date
    let licenseCategory: LicenseCategory
    let photoURL: URL?
    
    // If updates needed, return a new instance:
    func updated(name: String? = nil, photoURL: URL? = nil) -> UserProfileData {
        UserProfileData(
            name: name ?? self.name,
            examDate: self.examDate,
            licenseCategory: self.licenseCategory,
            photoURL: photoURL ?? self.photoURL,
            id: self.id,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
}