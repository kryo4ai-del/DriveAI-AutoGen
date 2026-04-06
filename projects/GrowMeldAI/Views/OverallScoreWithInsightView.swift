import SwiftUI
import Foundation
struct OverallScoreWithInsightView: View {
    let overallScore: Double // 0.75
    let categoryBreakdown: [CategoryInsight]
    let errorPatterns: [ErrorPattern]
    
    var body: some View {
        VStack(spacing: 16) {
            CircularProgressView(
                progress: overallScore,
                label: "Gesamtpunktzahl"
            )
            
            // ✅ NEW: Category breakdown with relative strength
            VStack(alignment: .leading, spacing: 12) {
                Text("Wo Du stark/schwach bist:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(categoryBreakdown.sorted(by: { $0.score > $1.score }), id: \.id) { category in
                    HStack(spacing: 8) {
                        // Relative strength indicator
                        if category.score > overallScore {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.green)
                        } else if category.score < overallScore - 0.15 {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(category.score * 100))%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        // Micro-feedback
                        Text(category.assessmentText)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // ✅ NEW: Error pattern insight (elaborative interrogation)
            if !errorPatterns.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deine häufigsten Fehler:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(errorPatterns, id: \.id) { pattern in
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pattern.description)
                                    .font(.caption)
                                
                                Text(pattern.suggestion)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        .padding(8)
                        .background(Color.yellow.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryInsight {
    let id: UUID
    let name: String
    let score: Double
    var assessmentText: String {
        if score >= 0.85 { return "Meisterschaft" }
        if score >= 0.70 { return "Gut" }
        return "Fokus nötig"
    }
}

struct ErrorPattern {
    let id: UUID
    let description: String // "Sie fehlen oft bei Zeit-Management-Fragen"
    let suggestion: String  // "Tipp: Übe zuerst die schnellen Antworten"
}