// ExamSyncQueue.swift
import Foundation

protocol SyncQueueObserver: AnyObject {
    func syncQueueDidUpdate(_ state: SyncQueueState)
}

// Actor ExamSyncQueue declared in Models/PendingExamSubmission.swift
