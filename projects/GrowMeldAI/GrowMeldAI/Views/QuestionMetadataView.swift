// Views/Components/QuestionMetadataView.swift
import SwiftUI

struct QuestionMetadataView: View {
    let metadata: QuestionMetadata
    let isFallbackMode: Bool
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        if isFallbackMode, shouldShowMetadata {
            VStack(alignment: .leading, spacing: 8) {
                metadataItemsSection
                
                if metadata.isHighFocusArea {
                    focusAreaBadge
                }
                
                Text(metadata.officialSourceLabel)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            // ADD: Respect motion preferences
            .transition(
                reduceMotion ? .opacity : .opacity.combined(with: .scale)
            )
        }
    }
    
    // ... rest of implementation
}