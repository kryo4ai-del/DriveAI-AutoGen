// LocalizationKeys.swift
enum LocalizationKeys {
    // Navigation
    static let navHome = "nav.home"
    static let navProfile = "nav.profile"
    
    // Onboarding
    static let onboardingTitle = "onboarding.title"
    static let onboardingExamDate = "onboarding.exam_date"
    
    // Questions
    static let questionCorrect = "question.correct"
    static let questionIncorrect = "question.incorrect"
    
    // Motivational (per Creative Director notes)
    static let motivationNearExam = "motivation.near_exam"
    static let motivationStreakMilestone = "motivation.streak_%d"
}

// Localizable.strings (de.lproj)
"nav.home" = "Startseite";
"nav.profile" = "Profil";
"onboarding.title" = "Willkommen zu DriveAI";
"question.correct" = "✓ Richtig! Du bist auf dem richtigen Weg.";
"question.incorrect" = "✗ Nicht ganz. Hier ist die Erklärung:";
"motivation.near_exam" = "Dein Prüfungstermin rückt näher — 3 Kategorien brauchen Wiederholung!";

// Usage in Views
Text(LocalizationKeys.questionCorrect, bundle: .main)