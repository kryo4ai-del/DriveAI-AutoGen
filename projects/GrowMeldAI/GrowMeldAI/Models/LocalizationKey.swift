import Foundation

/// Type-safe localization keys with region awareness
enum LocalizationKey: String, CaseIterable {
    // MARK: - Onboarding
    case onboarding_welcome_title = "onboarding.welcome.title"
    case onboarding_welcome_subtitle = "onboarding.welcome.subtitle"
    case onboarding_region_select_title = "onboarding.region.select.title"
    case onboarding_region_au = "onboarding.region.au"
    case onboarding_region_ca = "onboarding.region.ca"
    case onboarding_exam_date_label = "onboarding.exam_date.label"
    case onboarding_continue_button = "onboarding.continue.button"
    
    // MARK: - Dashboard
    case dashboard_title = "dashboard.title"
    case dashboard_progress_label = "dashboard.progress.label"
    case dashboard_exam_countdown = "dashboard.exam.countdown"
    case dashboard_days_remaining = "dashboard.days.remaining"
    case dashboard_start_practice = "dashboard.start.practice"
    
    // MARK: - Questions
    case question_title = "question.title"
    case question_of_total = "question.of.total"
    case question_select_answer = "question.select.answer"
    case question_correct = "question.correct"
    case question_incorrect = "question.incorrect"
    case question_explanation = "question.explanation"
    case question_next_button = "question.next.button"
    case question_previous_button = "question.previous.button"
    
    // MARK: - Exam Simulation
    case exam_start_title = "exam.start.title"
    case exam_duration_minutes = "exam.duration.minutes"
    case exam_question_count = "exam.question.count"
    case exam_pass_threshold = "exam.pass.threshold"
    case exam_start_button = "exam.start.button"
    case exam_timer_label = "exam.timer.label"
    case exam_paused = "exam.paused"
    case exam_resume_button = "exam.resume.button"
    
    // MARK: - Results
    case results_title = "results.title"
    case results_passed = "results.passed"
    case results_failed = "results.failed"
    case results_score = "results.score"
    case results_percentage = "results.percentage"
    case results_review_button = "results.review.button"
    case results_retry_button = "results.retry.button"
    
    // MARK: - Profile
    case profile_title = "profile.title"
    case profile_exam_date = "profile.exam.date"
    case profile_overall_score = "profile.overall.score"
    case profile_streak = "profile.streak"
    case profile_settings = "profile.settings"
    case profile_language = "profile.language"
    case profile_region = "profile.region"
    
    // MARK: - Common
    case common_cancel = "common.cancel"
    case common_ok = "common.ok"
    case common_error = "common.error"
    case common_retry = "common.retry"
    case common_loading = "common.loading"
}

/// Region-aware localization accessor
extension LocalizationKey {
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
    
    /// Localize with interpolation support
    func localized(with arguments: [CVarArg]) -> String {
        let format = NSLocalizedString(self.rawValue, comment: "")
        return String(format: format, arguments: arguments)
    }
}