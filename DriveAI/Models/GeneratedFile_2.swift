func fetchUserProgress() {
    isLoading = true

    // Simulate a fetch with potential failure
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let success = Bool.random() // Random success/failure for simulation
        if success {
            self.userProgress = UserProgress(completedQuizzes: 5, totalQuestions: 30, streak: 3)
            self.errorMessage = nil // Clear any previous error messages
        } else {
            self.errorMessage = "Failed to fetch user progress. Please try again."
        }
        self.isLoading = false
    }
}