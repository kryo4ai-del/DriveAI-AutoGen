// Domain/Models/DrivingTheoryReference.swift
struct DrivingTheoryReference {
    let stvoSection: String?      // e.g., "StVO §3"
    let trafficSignNumber: String? // e.g., "Zeichen 205"
    let legalExplanation: String   // localized German explanation
    let relatedSections: [String]  // cross-references
}

// Features/Questions/ViewModels/QuestionViewModel.swift
@MainActor