struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack {
            Text("Your Progress")
                .font(.title)
            NavigationLink("Start Quiz", destination: QuestionView(viewModel: QuestionViewModel()))
            NavigationLink("Categories", destination: CategoryOverviewView(viewModel: CategoryOverviewViewModel()))
            NavigationLink("Profile", destination: ProfileView(viewModel: ProfileViewModel()))
        }
        .padding()
    }
}