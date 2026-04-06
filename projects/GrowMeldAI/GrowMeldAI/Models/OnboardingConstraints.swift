import Foundation

/// Constants and constraints for the onboarding flow.
/// Centralizes magic numbers and makes them configurable.
enum OnboardingConstraints {
    /// Minimum days before exam date is allowed.
    static let minimumDaysUntilExam: Int = 14
    
    /// Maximum file size for captured photos (2 MB).
    static let maxPhotoFileSizeBytes: Int = 2 * 1024 * 1024
    
    /// Minimum name length (characters).
    static let minNameLength: Int = 2
    
    /// Maximum name length (characters).
    static let maxNameLength: Int = 100
    
    /// Timeout for camera capture operations (seconds).
    static let cameraOperationTimeout: TimeInterval = 30
}

extension Date {
    /// Returns the minimum allowed exam date (e.g., 14 days from now).
    static func minimumExamDate(
        minimumDays: Int = OnboardingConstraints.minimumDaysUntilExam
    ) -> Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        return calendar.date(byAdding: .day, value: minimumDays - 1, to: tomorrow)!
    }
}