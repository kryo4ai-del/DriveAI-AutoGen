import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let questionCount: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String,
        questionCount: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.questionCount = questionCount
    }
}

// Struct CategoryProgress declared in Models/CategoryProgress.swift
