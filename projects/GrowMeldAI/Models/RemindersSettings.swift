// Models/RemindersSettings.swift
import Foundation

struct RemindersSettings: Codable, Hashable {
    var isEnabled: Bool = true
    var frameAsTestOpportunity: Bool = true
    var selectedIntervals: [ReminderInterval] = [.tomorrow, .inThreeDays, .nextWeek]
    var customDate: Date?
    var showNextReviewDate: Bool = true
    var optimalReviewWindow: DateInterval?

    enum ReminderInterval: String, Codable, CaseIterable, Identifiable {
        case tomorrow = "Morgen"
        case inThreeDays = "In 3 Tagen"
        case nextWeek = "Nächste Woche"
        case beforeExam = "Vor dem Prüfungstermin"
        case custom = "Benutzerdefiniert"

        var id: String { rawValue }

        var dayInterval: Int {
            switch self {
            case .tomorrow: return 1
            case .inThreeDays: return 3
            case .nextWeek: return 7
            case .beforeExam: return 0 // Special case
            case .custom: return 0
            }
        }
    }
}