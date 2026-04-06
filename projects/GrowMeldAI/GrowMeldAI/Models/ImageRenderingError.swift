// ImageRenderingService.swift
import UIKit
import SwiftUI
import os.log

enum ImageRenderingError: Error, LocalizedError {
    case renderingFailed(String)
    case invalidCard
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .renderingFailed(let reason): return "Rendering failed: \(reason)"
        case .invalidCard: return "Invalid card for rendering"
        case .unknown(let reason): return reason
        }
    }
}

@MainActor