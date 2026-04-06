// ConsentUIProvider.swift
import UIKit
import SwiftUI

/// Protocol for presenting consent UI
protocol ConsentUIProvider {
    func presentConsentUI() async -> Bool
}

/// Default implementation using UIAlertController