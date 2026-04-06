// Features/Home/MainTabView.swift
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, categories, exam, profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }
                .tag(Tab.categories)
            
            ExamView()
                .tabItem {
                    Label("Exam", systemImage: "pencil.circle.fill")
                }
                .tag(Tab.exam)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
        }
    }
}