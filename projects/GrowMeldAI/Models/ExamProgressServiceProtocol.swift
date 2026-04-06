// File: Shared/Services/ExamProgressServiceProtocol.swift
import Foundation

/// Contract for exam readiness tracking.
/// Enables decoupling, testability, and platform independence.
protocol ExamProgressServiceProtocol: AnyObject {
    /// Exam readiness as percentage (0-100)
    var readinessPercent: Int { get }
    
    /// Weakest category name for focused learning
    var weakestCategory: String { get }
    
    /// Days remaining until exam, or nil if no exam scheduled
    var daysUntilExam: Int? { get }
}