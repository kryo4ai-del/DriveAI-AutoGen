// Utilities/AccessibleFonts.swift
import SwiftUI

struct AccessibleFonts {
    // Relative sizing (scales with Dynamic Type)
    static let headline = Font.headline
    static let body = Font.body
    static let caption = Font.caption
    
    // ❌ DO NOT USE FIXED SIZES:
    // static let headline = Font.system(size: 20)  // ← breaks with Large Text
}