// Models/ExamResult.swift

// Views/Common/NavigationContainer.swift
@MainActor
struct NavigationContainer: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var serviceContainer: ServiceContainer
    @State private var navPath = NavigationPath()
    @State private var selectedExamResult: ExamResult?
    
    enum Route: Hashable {
        case questionList(categoryId: String)
        case categoryBrowse
        case examStart
        case profile
    }
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                TabView {
                    // Questions Tab
                    QuestionListView(navPath: $navPath)
                        .environmentObject(serviceContainer)
                        .tabItem {
                            Label("Fragen", systemImage: "questionmark.circle.fill")
                        }
                    
                    // Home Tab
                    DashboardView(
                        onStartExam: { navPath.append(Route.examStart) },
                        onShowProfile: { navPath.append(Route.profile) }
                    )
                    .environmentObject(serviceContainer)
                    .tabItem {
                        Label("Start", systemImage: "house.fill")
                    }
                    
                    // Profile Tab
                    ProfileView()
                        .environmentObject(serviceContainer)
                        .tabItem {
                            Label("Profil", systemImage: "person.circle.fill")
                        }
                }
                .navigationDestination(for: Route.self) { route in
                    destination(for: route, navPath: $navPath)
                }
                .navigationDestination(item: $selectedExamResult) { result in
                    ExamResultView(result: result)
                        .environmentObject(serviceContainer)
                }
            }
        }
    }
    
    @ViewBuilder
    func destination(for route: Route, navPath: Binding<NavigationPath>) -> some View {
        switch route {
        case .questionList(let categoryId):
            QuestionListView(categoryId: categoryId, navPath: navPath)
                .environmentObject(serviceContainer)
        
        case .categoryBrowse:
            CategoryBrowseView(navPath: navPath)
                .environmentObject(serviceContainer)
        
        case .examStart:
            ExamView(
                onExamComplete: { result in
                    selectedExamResult = result
                }
            )
            .environmentObject(serviceContainer)
        
        case .profile:
            ProfileView()
                .environmentObject(serviceContainer)
        }
    }
}