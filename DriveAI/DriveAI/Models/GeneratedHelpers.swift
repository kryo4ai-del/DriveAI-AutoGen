.accessibilityLabel("Welcome to DriveAI")
    .accessibilityHint("Select your exam date to get started.")

// ---

.navigationBarTitleDisplayMode(.inline)

// ---

func validateExamDate() -> Bool {
      return examDate > Date() // Ensure it's a future date
  }
  
  func startLearning() {
      guard validateExamDate() else {
          // Handle invalid date scenario
          return
      }
      // Navigate to Dashboard
  }

// ---

func fetchQuestions() -> [Question]? {
      // Fetch logic with error catching
      do {
          // Attempt to read and parse questions
      } catch {
          // Handle error (e.g., log it and return nil)
          return nil
      }
  }