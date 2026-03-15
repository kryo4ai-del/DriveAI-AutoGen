struct ExamReadinessDashboardView: View {
    var body: some View {
        ExamCountdownView(countdown: snapshot.examCountdown) // ❌ Negative days?
    }
}
