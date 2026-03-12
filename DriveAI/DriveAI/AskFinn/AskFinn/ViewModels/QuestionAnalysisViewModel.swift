// ViewModels/QuestionAnalysisViewModel.swift
import Combine

class QuestionAnalysisViewModel: ObservableObject {
    @Published var analysisResult: AnalysisResult?
    
    private let questionAnalysisService = QuestionAnalysisService()
    
    func analyzeAnswer(userAnswer: UserAnswer) {
        analysisResult = questionAnalysisService.analyzeAnswer(userAnswer)
    }
}