// Views/KIIdentification/KIIdentificationSuccessView.swift

import SwiftUI

struct KIIdentificationSuccessView: View {
    let result: IdentificationResult
    let question: Question
    let onNext: () -> Void
    
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                // Celebration icon
                Image(systemName: result.isCorrect ? "star.fill" : "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(result.isCorrect ? .yellow : .blue)
                    .scaleEffect(showConfetti ? 1.1 : 1.0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6).repeatCount(2),
                        value: showConfetti
                    )
                
                Text(result.isCorrect ? "Sehr gut!" : "Korrekt!")
                    .font(.title.bold())
                    .foregroundColor(.primary)
            }
            .padding(.top, 20)
            
            // Response time display
            HStack(spacing: 8) {
                Image(systemName: "stopwatch.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.2f", result.responseTime) + " Sekunden")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // ⭐ Intrinsic Reward – Spaced Repetition Message
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "book.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                    
                    Text(result.motivationalMessage)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }
                .padding(12)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            
            // Learning context
            VStack(alignment: .leading, spacing: 12) {
                Divider()
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Kategorie")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(question.category)
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Nächste Wiederholung")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(Self.formatDate(result.nextReviewDate))
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action button
            Button(action: {
                triggerHapticFeedback()
                onNext()
            }) {
                HStack {
                    Image(systemName: "arrow.right")
                        .font(.caption)
                    Text("Nächste Frage")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .onAppear {
            showConfetti = true
            triggerHapticFeedback()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    // ✅ Localized accessibility label
    private var accessibilityLabel: String {
        let timeString = String(
            format: NSLocalizedString(
                "time_seconds_format",
                value: "%d seconds",
                comment: "Time duration in seconds"
            ),
            Int(result.responseTime)
        )
        return NSLocalizedString(
            "ki_success_accessibility",
            value: "Success! Completed in %@ seconds. %@",
            comment: "Success announcement"
        )
        .replacingOccurrences(of: "%@", with: timeString)
        .replacingOccurrences(of: "%@", with: result.motivationalMessage)
    }
    
    // ✅ Thread-safe, cached date formatter
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMM"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
    
    private static func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    // ✅ Thread-safe haptic feedback
    private func triggerHapticFeedback() {
        // Immediate feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.prepare()
        impact.impactOccurred()
        
        // Delayed follow-up with weak reference
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard self != nil else { return }  // ✅ Prevent use-after-free
            
            let notification = UINotificationFeedbackGenerator()
            notification.prepare()
            notification.notificationOccurred(.success)
        }
    }
}

#Preview {
    KIIdentificationSuccessView(
        result: IdentificationResult(
            isCorrect: true,
            responseTime: 2.34,
            timestamp: Date(),
            nextReviewDate: Date().addingTimeInterval(3 * 24 * 3600),
            motivationalMessage: "Blitzschnell! Diese Frage wird in 3 Tagen wieder abgefragt — du bist vorbereitet!"
        ),
        question: Question.preview,
        onNext: {}
    )
}