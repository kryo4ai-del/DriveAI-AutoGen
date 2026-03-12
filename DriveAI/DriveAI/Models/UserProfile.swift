struct UserProfile {
      var examDate: Date
      var totalScore: Int = 0
      var scoreStreak: Int = 0

      mutating func updateScore(by points: Int) {
          totalScore += points
          // Logic to update streak if necessary
      }
  }