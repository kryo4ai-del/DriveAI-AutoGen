import SwiftUI

// GOOD: Clear separation
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        Text("Dashboard")
    }
}

// DashboardViewModel declared in ViewModels/DashboardViewModel.swift