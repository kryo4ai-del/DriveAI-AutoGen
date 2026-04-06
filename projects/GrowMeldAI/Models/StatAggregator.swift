// Models/Aggregation/StatAggregator.swift
struct StatAggregator {
    /// Aggregate raw answers into category statistics
    static func aggregateAnswers(_ answers: [QuestionAnswer]) -> [CategoryStats] {
        var stats: [String: CategoryStats] = [:]
        
        for answer in answers {
            aggregate(answer, into: &stats)
        }
        
        return Array(stats.values)
    }
    
    private static func aggregate(_ answer: QuestionAnswer, into stats: inout [String: CategoryStats]) {
        let categoryID = answer.categoryID
        var stat = stats[categoryID] ?? CategoryStats(id: categoryID)
        
        stat.questionsAnswered += 1
        if answer.isCorrect {
            stat.correctAnswers += 1
        }
        stat.lastPracticedDate = answer.answeredDate
        stat.confidenceScore = stat.calculateConfidence()
        
        stats[categoryID] = stat
    }
    
    /// Update a single category's stats after new answers
    static func updateCategoryStats(_ stat: inout CategoryStats, withAnswers answers: [QuestionAnswer]) {
        let relevant = answers.filter { $0.categoryID == stat.id }
        for answer in relevant {
            aggregate(answer, into: &stat)
        }
    }
    
    private static func aggregate(_ answer: QuestionAnswer, into stat: inout CategoryStats) {
        stat.questionsAnswered += 1
        if answer.isCorrect {
            stat.correctAnswers += 1
        }
        stat.lastPracticedDate = answer.answeredDate
        stat.confidenceScore = stat.calculateConfidence()
    }
}

// Usage
let stats = StatAggregator.aggregateAnswers(userAnswers)
userProfile.categoryPerformance = stats