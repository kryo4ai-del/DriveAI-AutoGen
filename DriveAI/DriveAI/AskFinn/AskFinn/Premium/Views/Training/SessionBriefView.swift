// Views/Training/SessionBriefView.swift

import SwiftUI

/// Pre-session context frame shown before the first question.
///
/// Auto-dismisses after 2 seconds or on any tap.
/// Designed to feel like a transition, not a screen —
/// no navigation chrome, no interactive buttons beyond tap.
struct SessionBriefView: View {

    let previewText: String
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 36))
                    .foregroundColor(.green)

                Text(previewText)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
            }
            .opacity(opacity)
        }
        .contentShape(Rectangle())
        .onTapGesture { dismiss() }
        .onAppear {
            withAnimation(reduceMotion ? .none : .easeIn(duration: 0.3)) {
                opacity = 1
            }
            // Auto-dismiss after 2 seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dismiss()
            }
        }
        // VoiceOver: read the full sentence once on appear.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(previewText)
        .onAppear {
            UIAccessibility.post(notification: .announcement, argument: previewText)
        }
    }

    private func dismiss() {
        withAnimation(reduceMotion ? .none : .easeOut(duration: 0.2)) {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}
