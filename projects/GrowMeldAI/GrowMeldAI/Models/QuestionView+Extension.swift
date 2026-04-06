// QuestionView+ToxicityWarning.swift
import SwiftUI

extension QuestionView {
    @ViewBuilder
    func toxicityWarningOverlay(warnings: [ToxicityWarning]) -> some View {
        if !warnings.isEmpty {
            VStack(spacing: 8) {
                ForEach(warnings) { warning in
                    ToxicityWarningCardView(warning: warning)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}