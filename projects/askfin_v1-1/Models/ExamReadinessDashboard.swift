// Views/ExamReadinessDashboard.swift
import SwiftUI

struct ExamReadinessDashboard: View {
    @StateObject private var viewModel: ExamReadinessViewModel
    
    init(viewModel: ExamReadinessViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading readiness assessment...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                } else if let result = viewModel.readinessResult {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Main readiness gauge
                            ReadinessGaugeCard(score: result.score)
                            
                            // Pass probability
                            if let prediction = viewModel.prediction {
                                PredictionCard(prediction: prediction)
                            }
                            
                            // Weak areas
                            if !result.weakAreas.isEmpty {
                                WeakAreasSection(weakAreas: result.weakAreas)
                            }
                            
                            // Strengths
                            if !result.strengths.isEmpty {
                                StrengthsSection(strengths: result.strengths)
                            }
                            
                            // Recommended prep path
                            if !result.recommendations.isEmpty {
                                PrepPathSection(recommendations: result.recommendations)
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack {
                        Text("No Assessment Available")
                        Button("Try Again") {
                            Task { await viewModel.loadData() }
                        }
                    }
                }
            }
            .navigationTitle("Exam Readiness")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

// Supporting components
struct ReadinessGaugeCard: View {
    let score: ReadinessScore
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: score.readinessPercentage / 100)
                    .stroke(score.urgencyLevel.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: score.readinessPercentage)
                
                VStack {
                    Text("\(Int(score.readinessPercentage))%")
                        .font(.system(size: 44, weight: .bold, design: .default))
                    Text("Ready")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(score.urgencyLevel.displayText, systemImage: "calendar")
                        .font(.subheadline)
                    Spacer()
                    if let days = score.daysToExam {
                        Text("\(days) days")
                            .font(.caption)
                            .padding(4)
                            .background(score.urgencyLevel.color.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                Text("Pass probability: \(Int(score.estimatedPassProbability * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct PredictionCard: View {
    let prediction: ReadinessPrediction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pass Prediction")
                    .font(.headline)
                Spacer()
                Text("\(Int(prediction.passProbability * 100))%")
                    .font(.title3.bold())
                    .foregroundColor(prediction.passProbability >= 0.75 ? .green : .orange)
            }
            
            Text(prediction.recommendation)
                .font(.callout)
                .foregroundColor(.secondary)
            
            HStack {
                Label(prediction.confidenceLevel.displayText, systemImage: "checkmark.circle")
                    .font(.caption)
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct WeakAreasSection: View {
    let weakAreas: [WeakArea]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Areas for Improvement")
                .font(.headline)
            
            ForEach(weakAreas) { area in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(area.emoji)
                        VStack(alignment: .leading) {
                            Text(area.categoryName)
                                .font(.subheadline.bold())
                            Text("\(Int(area.score))% · \(area.recommendedPracticeQuestions) questions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    ProgressView(value: area.score / 100)
                        .tint(area.priority.badgeColor)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct StrengthsSection: View {
    let strengths: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Strengths")
                .font(.headline)
            
            ForEach(strengths, id: \.self) { strength in
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(strength)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct PrepPathSection: View {
    let recommendations: [PrepRecommendation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Study Plan")
                .font(.headline)
            
            ForEach(recommendations) { rec in
                VStack(alignment: .leading, spacing: 8) {
                    Text(rec.actionText)
                        .font(.subheadline.bold())
                    
                    HStack(spacing: 16) {
                        Label("\(rec.suggestedQuestions) Q", systemImage: "questionmark.circle")
                            .font(.caption)
                        
                        Label("\(rec.estimatedMinutes) min", systemImage: "clock")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.red)
            Text("Error Loading Readiness")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}