struct UserInfoView: View {
    var user: User
    
    var body: some View {
        Text("Your Exam Date: \(user.examDate, formatter: DateFormatter.localizedString(from: user.examDate, dateStyle: .medium, timeStyle: .none))")
            .padding()
            .accessibilityLabel("Your exam date is set for \(user.examDate, formatter: DateFormatter.localizedString(from: user.examDate, dateStyle: .medium, timeStyle: .none))")
            .accessibilityHint("This is the date you have chosen for your driver's license exam.")
    }
}