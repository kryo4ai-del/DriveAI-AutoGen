// Views/Components/Accessibility+Helpers.swift
import SwiftUI

extension View {
    /// Applies consistent accessibility container pattern
    func accessibilityContainer(
        label: String,
        value: String
    ) -> some View {
        self
            .accessibilityElement(children: .contain)
            .accessibilityLabel(label)
            .accessibilityValue(value)
    }
    
    /// For buttons with hint text
    func accessibilityButton(
        label: String,
        hint: String
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isButton)
    }
}