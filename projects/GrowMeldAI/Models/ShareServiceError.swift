// ShareService.swift
import UIKit
import SwiftUI
import os.log

enum ShareServiceError: Error, LocalizedError {
    case imageGenerationFailed(String)
    case invalidCard

    var errorDescription: String? {
        switch self {
        case .imageGenerationFailed(let reason): return "Image generation failed: \(reason)"
        case .invalidCard: return "Invalid shareable card"
        }
    }
}

// Class ShareService declared in Services/ShareService.swift
