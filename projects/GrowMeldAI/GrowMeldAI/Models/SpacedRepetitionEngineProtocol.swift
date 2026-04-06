// Services/Protocols/SpacedRepetitionEngineProtocol.swift
import Foundation

protocol SpacedRepetitionEngineProtocol {
    func calculateNextReviewDate(accuracy: Int, lastReviewDate: Date) -> Date
}