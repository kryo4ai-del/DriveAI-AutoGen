// SEOService.swift
import Foundation
import os.log

enum SEOServiceError: Error, LocalizedError {
    case invalidQuestion
    case metadataGenerationFailed
    case cardCreationFailed

    var errorDescription: String? {
        switch self {
        case .invalidQuestion: return "Invalid question data"
        case .metadataGenerationFailed: return "Failed to generate metadata"
        case .cardCreationFailed: return "Failed to create shareable card"
        }
    }
}

@MainActor