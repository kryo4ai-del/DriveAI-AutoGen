// Models/UI/QuestionDisplayState.swift
import Foundation

enum QuestionDisplayState {
    case loading
    case ready(question: Question)
    case answered(isCorrect: Bool, explanation: String)
    case completed
    case error(String)
}

enum AnswerSelectionState {
    case none
    case selected(index: Int)
    case locked(index: Int, isCorrect: Bool)
}