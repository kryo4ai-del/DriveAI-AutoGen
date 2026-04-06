struct ExamReadinessMeter: View {
    let categoryProgress: [String: CategoryProgress]
    let examDate: Date
    let practiceCount: Int
    
    var overallMastery: Double {
        guard !categoryProgress.isEmpty else { return 0 }
        let avgMastery = categoryProgress.values
            .map { $0.mastery }
            .reduce(0, +) / Double(categoryProgress.count)
        return avgMastery
    }
    
    var projectedPassChance: Double {
        // Simple model: current mastery predicts pass probability
        // (can be refined with Bayesian IRT later)
        return min(overallMastery, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Exam Readiness")
                    .font(.driveAIHeadline)
                Spacer()
                Text("\(Int(overallMastery * 100))%")
                    .font(.driveAITitle2)
                    .foregroundColor(AppColors.progress(overallMastery))
            }
            
            // Progress ring (circular progress indicator)
            ZStack {
                Circle()
                    .stroke(AppColors.secondaryBackground, lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: overallMastery)
                    .stroke(AppColors.progress(overallMastery), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(Int(overallMastery * 100))%")
                        .font(.driveAITitle2)
                    Text("Mastery")
                        .font(.driveAICaption2)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .frame(height: 120)
            
            // Exam simulation status
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.success)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(practiceCount) practice exams completed")
                        .font(.driveAIBody)
                    Text("Estimated pass chance: \(Int(projectedPassChance * 100))%")
                        .font(.driveAICaption2)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(12)
            .background(AppColors.secondaryBackground)
            .cornerRadius(8)
            
            // Days until exam countdown
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppColors.primary)
                Text("\(daysUntilExam) days until exam")
                    .font(.driveAIBody)
                    .foregroundColor(AppColors.text)
            }
            .padding(12)
            .background(
                examDate < Date().addingTimeInterval(86400 * 7)
                    ? AppColors.warning.opacity(0.2)
                    : AppColors.secondaryBackground
            )
            .cornerRadius(8)
        }
    }
    
    private var daysUntilExam: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
    }
}