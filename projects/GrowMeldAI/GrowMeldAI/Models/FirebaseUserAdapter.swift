enum FirebaseUserAdapter {
    static func toDomain(
        _ firebaseUser: User,
        userDefaults: UserDefaults
    ) -> AuthUser {
        let examDate: Date? = {
            // Cache access is thread-safe but marks intent
            userDefaults.object(forKey: "examDate_\(firebaseUser.uid)") as? Date
        }()
        
        return AuthUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
            createdAt: firebaseUser.metadata.creationDate ?? Date(),
            examDate: examDate
        )
    }
}