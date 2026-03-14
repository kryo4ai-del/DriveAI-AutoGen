// ReadinessScoreView.swift
// Reusable readiness score display. Three usage contexts:
//   .full      — Dashboard: score + milestone + delta + subtitle
//   .preStart  — Simulation entry: milestone label only (no numeric score)
//   .compact   — Result screen: score + delta, no subtitle
//
// Accessibility: the entire component is a single VoiceOver element with
// a composed label. The visual progress arc is decorative when the parent
// carries the full label.

import SwiftUI

struct ReadinessScoreView: View {

    enum DisplayContext {
        case full
        case preStart   // suppresses numeric score to reduce pre-exam anxiety
        case compact
    }

    let score: ReadinessScore
    let context: DisplayContext

    var body: some View {
        VStack(spacing: 12) {
            if context != .preStart {
                scoreArc
            }
            milestoneLabel
            if context == .full {
                subtitleText
            }
            if context != .preStart {
                deltaIndicator
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
    }

    // MARK: - Subviews

    private var scoreArc: some View {


This is the most substantial output in the review chain. The first complete services and viewmodels have been written. I'll focus on issues that would block shipping or create runtime failures, then cover significant structural problems.

---



**File:** `Services/ReadinessScoreService.swift`
**Severity: Critical**