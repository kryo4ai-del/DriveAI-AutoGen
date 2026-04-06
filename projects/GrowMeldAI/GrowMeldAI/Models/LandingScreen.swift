// Views/Landing/LandingScreen.swift
struct LandingScreen: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    LandingHeroSection()
                    LandingFeatureGrid()
                        .padding(.vertical, LandingMetrics.sectionSpacing)
                        .padding(.horizontal, LandingMetrics.paddingLarge)
                    LandingTestimonialSection()
                        .padding(.vertical, LandingMetrics.sectionSpacing)
                    LandingFAQSection()
                        .padding(.vertical, LandingMetrics.sectionSpacing)
                        .padding(.horizontal, LandingMetrics.paddingLarge)
                    Spacer(minLength: 100)
                }
            }
            
            LandingCTAFooter {
                appState.navigate(to: .onboarding)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .preferredColorScheme(nil)
    }
}