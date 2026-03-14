// Deliverable: Navigation/AppRouter.swift (additions)
enum AppRoute {
    case examReadiness
    case readinessDetail(categoryId: String)
    case categoryQuestionnaire(categoryId: String)
}

// Add to HomeView navigation:
NavigationLink(destination: ExamReadinessView(...)) {
    Label("Exam Readiness", systemImage: "target")
}