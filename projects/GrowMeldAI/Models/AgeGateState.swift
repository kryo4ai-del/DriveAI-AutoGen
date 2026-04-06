// Core/Models/AgeGateState.swift
import Foundation

enum AgeGateState: Equatable {
    case pending
    case approved
    case rejected
    case needsRetry
}