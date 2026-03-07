import Foundation

struct SettingOption: Identifiable {
    let id = UUID()
    let title: String
    var isOn: Bool // Represents toggleable settings such as notifications
    var description: String? // Optional description for additional context
}