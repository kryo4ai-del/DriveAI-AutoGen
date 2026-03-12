import SwiftUI

/// Root navigation controller.
/// Routes between OnboardingView (first launch) and HomeDashboardView (returning user).
/// HomeDashboardView owns its own NavigationStack - do NOT wrap it here.
struct AppNavigationView: View {
    @StateObject private var onboardingVM = OnboardingViewModel()

    var body: some View {
        if onboardingVM.isCompleted {
            HomeDashboardView()
                .environmentObject(onboardingVM)
        } else {
            NavigationStack {
                OnboardingView(viewModel: onboardingVM)
            }
        }
    }
}
