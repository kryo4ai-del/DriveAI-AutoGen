import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            OnboardingView() // Starting point of the app
        }
    }
}

// ---

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            OnboardingView() // Starting point of the app
                .navigationViewStyle(StackNavigationViewStyle()) // Ensure proper navigation on iPad
        }
    }
}

// ---

.onAppear {
       if isUserOnboarded {
           // Directly navigate to Home Dashboard
       }
   }

// ---

.onAppear {
       if viewModel.user != nil {
           // Directly navigate to Home Dashboard
       }
   }