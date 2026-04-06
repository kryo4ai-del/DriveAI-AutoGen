// Models/ExamFeedback.swift
struct ExamFeedback: Sendable {
    var title: String {
        result.passed 
            ? NSLocalizedString("exam.passed.title", 
                              defaultValue: "Bestanden! 🎉", 
                              comment: "Exam passed message")
            : NSLocalizedString("exam.failed.title", 
                              defaultValue: "Nicht bestanden 📚", 
                              comment: "Exam failed message")
    }
}

// Resources/de.lproj/Localizable.strings
"exam.passed.title" = "Bestanden! 🎉";
"exam.failed.title" = "Nicht bestanden 📚";

// Resources/en.lproj/Localizable.strings
"exam.passed.title" = "Passed! 🎉";
"exam.failed.title" = "Not Passed 📚";