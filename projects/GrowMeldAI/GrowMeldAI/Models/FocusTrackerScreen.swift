// Views/FocusTrackerScreen.swift
import SwiftUI

struct FocusTrackerScreen: View {
    @StateObject private var viewModel: FocusTrackerViewModel
    
    init(masteryService: MasteryCalculationServiceProtocol) {
        _viewModel = StateObject(
            wrappedValue: FocusTrackerViewModel(masteryService: masteryService)
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.masteryRecords.isEmpty {
                    ProgressView()
                } else {
                    scrollContent
                }
            }
            .navigationTitle("Lernfortschritt")
            .onAppear {
                viewModel.refresh()
            }
        }
    }
    
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                overallProgressCard
                readinessCard
                categoriesSection
            }
            .padding()
        }
    }
    
    private var overallProgressCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Gesamtfortschritt")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 6)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.overallMastery / 100)
                        .stroke(
                            viewModel.overallMastery >= 80 ? Color.green : Color.yellow,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.overallMastery)
                    
                    VStack(spacing: 2) {
                        Text("\(Int(viewModel.overallMastery))")
                            .font(.title2.bold())
                        Text("%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 100, height: 100)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bestanden: \(viewModel.masteryRecords.filter { $0.isReadyForExam }.count)/\(viewModel.masteryRecords.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.allCategoriesReady ? "checkmark.circle.fill" : "hourglass.circle")
                            .foregroundColor(viewModel.allCategoriesReady ? .green : .orange)
                        
                        Text(viewModel.allCategoriesReady ? "Bereit!" : "Üben erforderlich")
                            .font(.body.bold())
                            .foregroundColor(viewModel.allCategoriesReady ? .green : .orange)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var readinessCard: some View {
        Group {
            if viewModel.allCategoriesReady {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Du bist bereit für die Prüfung!")
                            .font(.body.bold())
                        Spacer()
                    }
                    
                    Text("Alle Kategorien haben 80% oder mehr erreicht.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            } else {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .foregroundColor(.orange)
                        Text("Noch mehr üben!")
                            .font(.body.bold())
                        Spacer()
                    }
                    
                    let notReady = viewModel.masteryRecords.filter { !$0.isReadyForExam }
                    if let weakest = notReady.min(by: { $0.masteryPercentage < $1.masteryPercentage }) {
                        Text("Fokus auf: \(weakest.categoryName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Nach Kategorie")
                    .font(.headline)
                Spacer()
            }
            
            if viewModel.masteryRecords.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.richtext")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Keine Daten vorhanden")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.masteryRecords) { record in
                        CategoryMasteryRow(mastery: record)
                    }
                }
            }
        }
    }
}

struct CategoryMasteryRow: View {
    let mastery: MasteryRecord
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mastery.categoryName)
                        .font(.body.bold())
                    
                    Text("\(mastery.correctAnswers)/\(mastery.totalAnswers) richtig")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(mastery.masteryPercentage)%")
                        .font(.body.bold())
                        .foregroundColor(mastery.masteryColor)
                    
                    HStack(spacing: 4) {
                        Image(systemName: mastery.isReadyForExam ? "checkmark" : "xmark")
                            .font(.caption2.bold())
                            .foregroundColor(mastery.masteryColor)
                        
                        Text(mastery.isReadyForExam ? "Bestanden" : "Nicht bestanden")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            ProgressView(value: Double(mastery.masteryPercentage), total: 100)
                .tint(mastery.masteryColor)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    let mockService = MockMasteryService()
    FocusTrackerScreen(masteryService: mockService)
}