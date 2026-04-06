// Features/Shared/Components/AccessibleText.swift
import SwiftUI
struct AccessibleText: View {
    let text: String
    let fontSize: Font
    let isImportant: Bool
    
    var body: some View {
        Text(text)
            .font(fontSize)
            .dynamicTypeSize(.xSmall ... .xxxLarge)  // Respect system text size
            .accessibilityAddTraits(isImportant ? .isHeader : [])
            .accessibilityLabel(text)
            .foregroundColor(.primary)  // Accessible default color
    }
}

// Features/Question/Views/AnswerOption.swift
// Struct AnswerOption declared in Models/AnswerOptionButton.swift
