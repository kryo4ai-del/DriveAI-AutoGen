// ❌ CURRENT (UNDEFINED SCHEMA)
// What does Firestore look like?
// How is data nested?
// What are the field types?

// ✅ REQUIRED (Schema definition)
// Firestore Collection Structure:
//
// users/{uid}
//   ├── profile
//   │   ├── locale: "de"
//   │   ├── examDate: timestamp
//   │   ├── createdAt: timestamp
//   │   └── updatedAt: timestamp
//   │
//   ├── progress/{categoryId}
//   │   ├── correct: 45
//   │   ├── total: 100
//   │   ├── lastAttempted: timestamp
//   │   └── updatedAt: timestamp
//   │
//   └── settings
//       ├── notificationsEnabled: bool
//       ├── darkModeEnabled: bool
//       └── updatedAt: timestamp

// Swift model:
struct FirestoreUser: Codable {
    @DocumentID var uid: String
    var profile: UserProfile
    var progress: [String: CategoryProgress]  // categoryId -> stats
    var settings: UserSettings
}

struct CategoryProgress: Codable {
    var correct: Int
    var total: Int
    var lastAttempted: Date
    var updatedAt: Date
}