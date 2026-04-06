// AnalyticsEventQueue.swift
import Foundation
import os

// Actor AnalyticsEventQueue declared in Models/StoredAnalyticsEvent.swift

enum AnalyticsError: Error {
    case timeout
    case serializationFailed
    case networkFailure
}