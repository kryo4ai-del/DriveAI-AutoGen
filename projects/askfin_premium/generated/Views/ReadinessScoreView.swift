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
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 8)
            Circle()
                .trim(from: 0, to: CGFloat(score.score) / 100.0)
                .stroke(
                    milestoneColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: score.score)

            Text("\(score.score)%")
                .font(.system(size: context == .compact ? 20 : 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: context == .compact ? 60 : 100, height: context == .compact ? 60 : 100)
    }

    private var milestoneLabel: some View {
        Text(score.milestone.displayName)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(milestoneColor)
    }

    private var subtitleText: some View {
        Text(score.milestone.motivationalSubtitle)
            .font(.footnote)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var deltaIndicator: some View {
        if let deltaDisplay = score.deltaDisplay {
            let isPositive = (score.delta ?? 0) > 0
            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2.weight(.bold))
                Text(deltaDisplay)
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(isPositive ? .green : .orange)
        }
    }

    // MARK: - Milestone Color

    private var milestoneColor: Color {
        switch score.milestone {
        case .amAnfang:         Color(.systemGray)
        case .grundlagenGelegt: Color(.systemRed)
        case .aufDemWeg:        Color(.systemOrange)
        case .fastBereit:       Color(.systemYellow)
        case .pruefungsbereit:  Color(.systemGreen)
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        "Prüfungsbereitschaft"
    }

    private var accessibilityValue: String {
        var parts = ["\(score.score) Prozent", score.milestone.displayName]
        if let delta = score.delta, delta != 0 {
            let direction = delta > 0 ? "gestiegen" : "gesunken"
            parts.append("um \(abs(delta)) Punkte \(direction)")
        }
        return parts.joined(separator: ", ")
    }
}
