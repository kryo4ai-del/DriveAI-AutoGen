// Color+Hex.swift
// Shared hex initialiser used by BreathFlowColors and any other DriveAI color file.

import SwiftUI

extension Color {
    /// Initialises a Color from a 6-character hex string (e.g. "34D399").
    /// The leading `#` is stripped automatically if present.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8)  & 0xFF) / 255.0
        let b = Double(int         & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}