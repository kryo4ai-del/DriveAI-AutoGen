// Models/MasteryRecord.swift
import Foundation
import SwiftUI

struct MasteryRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let correctAnswers: Int
    let totalAnswers: Int
    let lastUpdated: Date
    
    var masteryPercentage: Int {
        guard totalAnswers > 0 else { return 0 }
        return (correctAnswers * 100) / totalAnswers
    }
    
    var isReadyForExam: Bool {
        masteryPercentage >= 80
    }
    
    var masteryColor: Color {
        switch masteryPercentage {
        case 0..<50: return .red
        case 50..<80: return .yellow
        default: return .green
        }
    }
}