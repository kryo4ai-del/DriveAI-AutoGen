// ❌ BAD: Component has state
import SwiftUI
struct QuestionOption: View {
    @State var isSelected = false  // WRONG
    var body: some View { /* ... */ }
}

// ✅ GOOD: Component receives binding
// Struct QuestionOption declared in Models/QuestionOption.swift
