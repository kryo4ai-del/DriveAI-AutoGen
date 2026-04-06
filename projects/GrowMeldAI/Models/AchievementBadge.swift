// Alternative: In-app achievement system (compliant)
   struct AchievementBadge: Identifiable {
       let id: String
       let title: String
       let description: String
       let imageName: String
       let isSharedToInstagram: Bool // Always false
   }