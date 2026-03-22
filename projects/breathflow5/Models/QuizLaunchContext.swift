import Foundation

// QuizLaunchContext.swift
   /// Represents the state needed to launch a quiz
   struct QuizLaunchContext {
       let exerciseID: String
       let category: ExerciseCategory
       let mode: QuizMode  // review, practice, challenge
       let sourceAccessPoint: AccessPoint
       let userAuthState: AuthState
   }
   
   // NavigationPath.swift
   /// Represents a navigation action from quick access
   enum NavigationPath {
       case resumeLastQuiz
       case quickReviewWeakAreas
       case practiceTodaysChallenge
       case reviewCategory(ExerciseCategory)
       case custom(exerciseID: String, mode: QuizMode)
   }
   
   // AccessPoint.swift
   /// Where the user initiated the quick access
   enum AccessPoint {
       case homeScreenButton
       case notificationTap
       case deepLink(url: URL)
       case smartSuggestion
       case appShortcut
   }