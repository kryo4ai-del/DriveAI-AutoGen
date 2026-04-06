// DriveAI/Data/Mappers/APIQuestion+Mapper.swift
import Foundation

extension APIQuestion {
    func toDomain() -> Question {
        return Question(
            id: id,
            text: text,
            categoryId: categoryId,
            imageUrl: imageUrl,
            answers: answers.map { $0.toDomain() },
            correctAnswerId: correctAnswerId,
            explanation: explanation,
            difficulty: Question.Difficulty(rawValue: difficulty) ?? .medium,
            isAnswered: false,
            userAnswerId: nil,
            version: version,
            syncedAt: ISO8601DateFormatter().date(from: updatedAt) ?? Date()
        )
    }
}

extension APIAnswer {
    func toDomain() -> Answer {
        Answer(
            id: id,
            text: text,
            imageUrl: imageUrl
        )
    }
}

extension APICategory {
    func toDomain(isSynced: Bool = true) -> Category {
        Category(
            id: id,
            name: name,
            description: description,
            questionCount: questionCount,
            order: order,
            isSynced: isSynced
        )
    }
}